--------------------------------------------------------
--  DDL for Function F_PENALIZACION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PENALIZACION" (
   pctipmov IN NUMBER,
   nanyos IN NUMBER,
   psproduc IN parproductos.sproduc%TYPE,
   psseguro IN seguros.sseguro%TYPE,
   pfecha IN DATE,
   pipenali OUT NUMBER,
   ptippenali OUT NUMBER,
   ptablas IN VARCHAR2 DEFAULT 'SEG',
   pmodo IN NUMBER DEFAULT 1)
   RETURN NUMBER AUTHID CURRENT_USER IS
    /******************************************************************************
       NOMBRE:     f_penalizacion
       PROPÓSITO:  Funciones calculo penalización

       REVISIONES:
       Ver        Fecha     Autor    Descripción
       ------  ----------  --------  ------------------------------------
       1.0     XX/XX/XXXX   XXX      1. Creación del package.
       1.1     25/11/2010   JRH      2. 0016833: F_PENALIZACION incorrecta
         ********************************************************************************************//*******************************************************************************************
     12/02/07. Tarea 1345: Antes de mirar la penalización por producto, se mira si hay penalización
               definida a nivel de póliza.
     05/03/07. Tarea 1345: Se pasa el parámetro porigen en la llamada a pac_calculo_formulas.calc_formul
               en función del parámetro de entrada ptablas
     24/05/07. Tarea 17. Se añade el parámetro PMODO donde
               pmodo = 1 --> Calcula la penalización a nivel de póliza
               pmodo = 2 --> Calcula la penalización a nivel de producto
   ********************************************************************************************/
   p_ipenali      detprodtraresc.ipenali%TYPE;
   p_ppenali      detprodtraresc.ppenali%TYPE;
   p_clave        detprodtraresc.clave%TYPE;
   num_err        NUMBER := 0;
   trobat         NUMBER := 1;
   porigen        NUMBER;
BEGIN
   IF pmodo = 1 THEN
      --información a nivel de poliza
      IF ptablas = 'EST' THEN
--        porigen := 1;
         BEGIN
            SELECT ipenali, ppenali, clave
              INTO p_ipenali, p_ppenali, p_clave
              FROM estpenaliseg e
             WHERE e.sseguro = psseguro
               AND e.ctipmov = pctipmov
               AND e.niniran = (SELECT MIN(ee.niniran)
                                  FROM estpenaliseg ee
                                 WHERE ee.sseguro = e.sseguro
                                   AND ee.nmovimi = e.nmovimi
                                   AND ee.ctipmov = e.ctipmov
                                   AND nanyos BETWEEN ee.niniran AND ee.nfinran)
               AND e.nmovimi = (SELECT MAX(e1.nmovimi)
                                  FROM estpenaliseg e1
                                 WHERE e.sseguro = e1.sseguro
                                   AND e.ctipmov = e1.ctipmov
                                   AND e.niniran = e1.niniran);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               trobat := 0;
            WHEN OTHERS THEN
               p_tab_error
                        (f_sysdate, f_user, 'F_PENALIZACION', NULL,
                         'Error no controlado al buscar información de la tabla estpenaliseg',
                         SQLERRM);
               RETURN 109550;
         END;
      ELSIF ptablas = 'SEG' THEN
--        porigen := 2;
         BEGIN
            SELECT ipenali, ppenali, clave
              INTO p_ipenali, p_ppenali, p_clave
              FROM penaliseg p
             WHERE p.sseguro = psseguro
               AND p.ctipmov = pctipmov
               AND p.niniran = (SELECT MIN(ee.niniran)
                                  FROM penaliseg ee
                                 WHERE ee.sseguro = p.sseguro
                                   AND ee.nmovimi = p.nmovimi
                                   AND ee.ctipmov = p.ctipmov
                                   AND nanyos BETWEEN ee.niniran AND ee.nfinran)
               AND p.nmovimi = (SELECT MAX(p1.nmovimi)
                                  FROM penaliseg p1, movseguro mov
                                 WHERE p.sseguro = p1.sseguro
                                   AND p.ctipmov = p1.ctipmov
                                             -- BUG 16833 - 11/2010 - JRH  - 0016833: F_PENALIZACION incorrecta
                                   --   AND P.NINIRAN = P1.NINIRAN
                                          -- Fi BUG 16833 - 11/2010 - JRH
                                   AND p1.sseguro = mov.sseguro
                                   AND p1.nmovimi = mov.nmovimi
                                   AND mov.fefecto <= pfecha);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               trobat := 0;
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'F_PENALIZACION', NULL,
                           'Error no controlado al buscar información de la tabla penaliseg',
                           SQLERRM);
               RETURN 109550;
         END;
      ELSIF ptablas = 'SOL' THEN
--        porigen := 0;
         trobat := 0;   -- Se fuerza el valor de la variable para que busque la penalizacion a nivel de producto
      END IF;
   ELSE   -- pmodo = 2
      trobat := 0;
   END IF;

   IF ptablas = 'EST' THEN
      porigen := 1;
   ELSIF ptablas = 'SEG' THEN
      porigen := 2;
   ELSIF ptablas = 'SOL' THEN
      porigen := 0;
   END IF;

   IF trobat = 0 THEN
      --información a nivel de producto
      SELECT d.ipenali, d.ppenali, d.clave
        INTO p_ipenali, p_ppenali, p_clave
        FROM detprodtraresc d, prodtraresc p
       WHERE d.sidresc = p.sidresc
         AND p.sproduc = psproduc
         AND p.ctipmov = pctipmov
         AND p.finicio <= pfecha
         AND(p.ffin > pfecha
             OR p.ffin IS NULL)
         AND d.niniran = (SELECT MIN(dp.niniran)
                            FROM detprodtraresc dp
                           WHERE dp.sidresc = d.sidresc
                             AND nanyos BETWEEN dp.niniran AND dp.nfinran);
   END IF;

   --Miro si la penalitzacio es una formula
   IF p_clave IS NOT NULL THEN
      IF p_ppenali IS NOT NULL THEN
         ptippenali := 2;
      ELSIF p_ipenali IS NOT NULL THEN
         ptippenali := 1;
      END IF;

      --  DBMS_OUTPUT.put_line('f_penalizacion. porigen =' || porigen);
      num_err := pac_calculo_formulas.calc_formul(pfecha, psproduc, NULL, NULL, NULL, psseguro,
                                                  p_clave, pipenali, NULL, NULL, porigen);
   --  DBMS_OUTPUT.put_line('pipenali =' || pipenali);
   ELSIF p_ppenali IS NOT NULL THEN
      ptippenali := 2;   --Percentatge
      pipenali := p_ppenali;   --PErcentatge de la penalitzacio
   ELSIF p_ipenali IS NOT NULL THEN
      ptippenali := 1;   --Import
      pipenali := p_ipenali;   --Import de la penalitzacio
   ELSE
      RETURN 109550;
   END IF;

   RETURN num_err;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      -- NO HAY PENALIZACION
      pipenali := 0;
      ptippenali := 2;
      RETURN 0;
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, 'F_penalizacion', NULL,
                  'sseguro =' || psseguro || 'fecha =' || pfecha, SQLERRM);
      --  DBMS_OUTPUT.put_line(SQLERRM);
      RETURN 109550;
END f_penalizacion;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_PENALIZACION" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PENALIZACION" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PENALIZACION" TO "PROGRAMADORESCSI";
