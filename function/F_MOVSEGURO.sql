create or replace FUNCTION f_movseguro(
   psseguro IN NUMBER,
   pnrecibo IN NUMBER,
   pcmotmov IN NUMBER,
   pcmovseg IN NUMBER,
   pfefecto IN DATE,
   pcanuext IN NUMBER,
   pnsuplem IN NUMBER,
   pcimpres IN NUMBER,
   pmescon IN DATE,
   pmovini OUT NUMBER,
   pfemisio IN DATE DEFAULT NULL,
   pdomper IN NUMBER DEFAULT NULL,
   pcmotven IN NUMBER DEFAULT NULL,
   pnum_emp IN NUMBER DEFAULT NULL,
   pcregul IN NUMBER DEFAULT NULL)   -- BUG 34462 - AFM
   RETURN NUMBER AUTHID CURRENT_USER IS
/***************************************************************************
   F_MOVSEGURO    Genera un movimiento en MOVSEGURO
            Retorna 0 si todo va bien, sino 1
   ALLIBCTR
     REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        -----------   ----              --------------
      2.0        19/12/2011   JRH              2.0 20206: Prestaciones PPA
    ******************************************************************************/

   /*
   --  Afegim el camp SMOVSEG
   --  Esborrem el camp SMOVSEG. Retornem el nmovimi nou
   --  Se añade el campo NCUACOA/ Se quita otra vez
   --  Si el parametro pcimpres = null, entonces ponemos
   --       cimpres del último movimiento.
   --  Se añade el parámetro pfemisio.
   --  Si el parámetro pnsuplem = null, entonces ponemos
   --       nsuplem del último movimiento
   --  Añadimos el campo CUSUMOV
     --       fcontab se grabará a NULL.
   --         El valor de cmovseg en movseguro ya no será el que llegue
   --                     como parámetro sino el resultante del acceso a codimotmov
   --         s' afegeix un nou parmetre (pcmotven default null)
   --       i s' inserta a movrecibo
   --         es canvia el return 1 de les excepcions per el codi
   --       del literal que indica el  numero d'error.
   --         se ha añadido un campo en movseguro (COFICIN) que sólo se informará
   --        si el parámetro de instalación OF_MOVSEG está informado
   --         Se modifica el significado del parámetro OF_MOVSEG que a partir de
   --        ahora tendrá el valor de la oficina por defecto en el caso que deba grabarse
   --       la oficina en la tabla MOVSEGURO. Para saber si debe grabarse la oficina
   --       en la tabla MOVSEGURO o no, debe leerse el parámetro OF_MOVSEG? (que tiene
   --       los valores, SI o otros)
   --      bug 8769-- CIV - Gravar l'oficina en el camp COFICINA de MOVSEGURO
   --  * BUG 34462 - Suplementos de Convenios (retroactivos)
   --    BUG 3324 - SGM Interacción del Rango DIAN con la póliza (No. Certificado)
   ***************************************************************************/
   mov            NUMBER;
   cua            NUMBER;
   impres         NUMBER;
   xcimpres       NUMBER;
   xfemisio       DATE;
   suplem         NUMBER;
   xnsuplem       NUMBER;
   wcmovseg       NUMBER;
   v_coficin      NUMBER;
   vofimovseg     VARCHAR2(2);
   num_err        NUMBER;
   vcagente       NUMBER;
   v_num_emp      movseguro.nempleado%TYPE;
BEGIN
   -- DBMS_OUTPUT.put_line('entramos en movseguro');

   -- Miramos cual es el nº del último movimiento del seguro
   BEGIN
      SELECT MAX(nmovimi)
        INTO mov
        FROM movseguro
       WHERE sseguro = psseguro;

      -- Miramos el nº de cuadro de coaseguro del último movimiento.
      --    (Ya no se mira el coaseguro)
      --  Y el estado de impresion
      --DBMS_OUTPUT.put_line(' mov =' || mov);
      IF mov IS NOT NULL THEN
         SELECT cimpres, nsuplem
           INTO impres, suplem
           FROM movseguro
          WHERE sseguro = psseguro
            AND nmovimi = mov;

         mov := mov + 1;
      ELSE
         impres := 0;
         suplem := 0;
         mov := 1;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 104349;
   END;

   pmovini := mov;

   -- Si pcimpres = null , ponemos el cimpres del movimiento anterior
   IF pcimpres IS NULL THEN
      xcimpres := impres;
   ELSE
      xcimpres := pcimpres;
   END IF;

   -- Si pnsuplem = null , ponemos el nsuplem del movimiento anterior
   IF pnsuplem IS NULL THEN
      xnsuplem := suplem;
   ELSE
      xnsuplem := pnsuplem;
   END IF;

   -- Dependiendo del tipo de movimiento se pone la fecha de emision.
   -- Si es de anulacion o rehabilitación , el valor que entra por parámetro
-- es pfemisio = null, pero pfemisio tomara el valor de F_SYSDATE, igual que fmovimi.
-- Son movimientos que no se emiten.
   BEGIN
      SELECT cmovseg
        INTO wcmovseg
        FROM codimotmov
       WHERE cmotmov = pcmotmov;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 105561;
   END;

   IF wcmovseg = 3
      OR wcmovseg = 4 THEN
      xfemisio := TRUNC(f_sysdate);
   ELSIF(wcmovseg = 2
         AND(NVL
                (pac_parametros.f_parempresa_n
                                              (pac_parametros.f_parinstalacion_n('EMPRESADEF'),
                                               'FEC_EMIS_CARTERA_DIA'),
                 0) = 1)) THEN
      xfemisio := TRUNC(f_sysdate);
   ELSE
      xfemisio := pfemisio;
   END IF;

   -- Se retiene o desretiene la póliza según el cmovseg
   IF wcmovseg = 10 THEN
      num_err := f_act_hisseg(psseguro, mov - 1);

      UPDATE seguros
         SET creteni = 1   -- RETINGUDA (detvalores 66)
       WHERE sseguro = psseguro;
   -- Bug 20206 - 19/11/2011 - JRH - Desretención pólizas para el cmovseg 12 (Prestaciones)
   ELSIF wcmovseg IN(11, 12) THEN
      -- Fi Bug 20206 - 19/11/2011 - JRH
      num_err := f_act_hisseg(psseguro, mov - 1);

      UPDATE seguros
         SET creteni = 0   -- NORMAL (detvalores 66)
       WHERE sseguro = psseguro;
   END IF;

-- Se da de alta un registro en MOVSEGURO
-- Es suprimeix el camp NRECIBO de MOVSEGURO
-- Añadimos el campo CUSUMOV

   -- si el parámetro OF_MOVSEG? tiene el valor SI, entonces se informará el campo COFICIN
    /*
     vofimovseg := F_Parinstalacion_T('OF_MOVSEG?');
    IF vofimovseg = 'SI' THEN
      V_COFICIN := pk_nueva_produccion.F_OFICINA_MV;
      IF v_coficin IS NULL THEN
       RETURN 101378;--codigo de agente incorrecto
     END IF;
   ELSE
      v_coficin :=  NULL;
   END IF;
    */
    -- bug 8769--INI
   num_err := pac_user.f_get_cagente(f_user, vcagente);

   IF num_err <> 0 THEN
      RETURN 101378;   --codigo de agente incorrecto
   ELSE
      v_coficin := vcagente;
   END IF;

   -- bug 8769--FIN

   -- Bug 9825 - APD - 16/06/2009 -
   -- Antes de grabar en movseguro miremos si el parámetro pnum_emp IS NULL.
   -- Si lo es, se hace una llamada a PAC_USER.f_get_empleado para obtenerlo
   IF pnum_emp IS NULL THEN
      num_err := pac_user.f_get_empleado(f_user, v_num_emp);

      IF num_err <> 0 THEN
         RETURN 111261;   -- No existe el número de empleado.
      END IF;
   ELSE
      v_num_emp := pnum_emp;
   END IF;
   -- Bug 9825 - APD - 16/06/2009 - Fin
   
   -- INI BUG 3324 - SGM Interacción del Rango DIAN con la póliza (No. Certificado)
   -- INI IAXIS 5273 - SGM se mueve a p_emitir_propuesta para evitar crear cert dian en cotizacion
/*   num_err := PAC_RANGO_DIAN.f_asigna_rangodian(psseguro,mov);
   IF num_err <> 0 THEN
      RETURN num_err;   --codigo de agente incorrecto
   END IF;*/  
   -- FIN BUG 3324 - SGM Interacción del Rango DIAN con la póliza (No. Certificado)   
   
   BEGIN
      INSERT INTO movseguro
                  (sseguro, fmovimi, nmovimi, cmotmov, cmovseg, fefecto, fcontab,
                   cimpres, nsuplem, canuext, femisio, cusumov, cdomper, cmotven,
                   nempleado, coficin, cregul)   -- BUG 34462 - AFM
           VALUES (psseguro, f_sysdate, mov, pcmotmov, wcmovseg, TRUNC(pfefecto), NULL,
                   xcimpres, xnsuplem, pcanuext, xfemisio, f_user, pdomper, pcmotven,
                   v_num_emp, v_coficin, pcregul);   -- BUG 34462 - AFM
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_movseguro', 1, 'error_no_controlado', SQLERRM);
         RETURN 105235;
   END;



-- Si todo ha ido bien
   RETURN 0;
END f_movseguro;
/
