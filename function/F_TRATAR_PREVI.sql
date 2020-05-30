--------------------------------------------------------
--  DDL for Function F_TRATAR_PREVI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_TRATAR_PREVI" (tipo		VARCHAR2)
RETURN NUMBER IS
  v_ram		cnvpolizas.ram%TYPE;
  v_moda		cnvpolizas.moda%TYPE;
  v_tipo		cnvpolizas.tipo%TYPE;
  v_cole		cnvpolizas.cole%TYPE;
  v_sseguro		cnvpolizas.sseguro%TYPE;
  v_error		NUMBER;
  v_cidioma		NUMBER := null;
  v_nom_cli		comp_previ.nom_cli%TYPE;
  v_pbruta		comp_previ.pbruta%TYPE;
  v_comis 		comp_previ.comis%TYPE;
BEGIN
  FOR reg IN ( SELECT *
                 FROM comp_previ
             )
  LOOP
    BEGIN
      v_error := 0;
      BEGIN
        SELECT ram, moda, tipo, cole, sseguro
          INTO v_ram, v_moda, v_tipo, v_cole, v_sseguro
          FROM cnvpolizas cp1, cnvproductos cp2
         WHERE cp2.numpol = ltrim(reg.pol_colec,'0')
           AND cp1.polissa_ini = to_char(reg.polissa)
           AND cp1.sistema IN (SELECT DISTINCT sistema FROM cnvpolizas)
           AND cp1.ram = cp2.cramo
           AND cp1.moda = cp2.cmodal
           AND cp1.tipo = cp2.ctipseg
           AND cp1.cole = cp2.ccolect;
      EXCEPTION
        WHEN others THEN
          v_error := 1;
          dbms_output.put_line('Error al obtener sseguro. POLISSA = '||reg.polissa||
                               ', POL_COLEC = '||reg.pol_colec||
                               ', SQLERRM: '||sqlerrm);
      END;
      IF v_error = 0 THEN
        IF reg.nom_cli IS NULL THEN
          v_error := f_asegurado(v_sseguro,1,v_nom_cli,v_cidioma);
        END IF;
        IF tipo = 'C' THEN
          v_pbruta := reg.pneta + reg.rec_exter + reg.impostos + reg.consorci +
                      reg.dgs + reg.arbitrio + reg.fng - reg.bonifica;

          v_comis := v_pbruta * reg.comis;
        END IF;
        UPDATE comp_previ
           SET cramo = v_ram,
               cmodali = v_moda,
               ctipseg = v_tipo,
               ccolect = v_cole,
               sseguro = v_sseguro,
               nom_cli = nvl(nom_cli,v_nom_cli),
               pbruta = decode(tipo,'W',pbruta,v_pbruta),
               comis = decode(tipo,'W',comis,v_comis)
         WHERE polissa = reg.polissa
           AND pol_colec = reg.pol_colec;
      END IF;
    EXCEPTION
      WHEN others THEN
        dbms_output.put_line('Error inesperado en POLISSA = '||reg.polissa||
                             ', POL_COLEC = '||reg.pol_colec||
                             ', SQLERRM: '||sqlerrm);
        return v_error;
    END;
  END LOOP;
  return v_error;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_TRATAR_PREVI" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_TRATAR_PREVI" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_TRATAR_PREVI" TO "PROGRAMADORESCSI";
