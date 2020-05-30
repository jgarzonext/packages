/* Formatted on 2019/10/11 15:27 (Formatter Plus v4.8.8) */
--------------------------------------------------------
--  DDL for Package Body PAC_COMISIONEGOCIO
--------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY pac_comisionegocio
AS
   /******************************************************************************
     NOMBRE:     pac_comisionegocio
     PROPÓSITO:  Package para gestionar los convenios de comisión especial

     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        19/12/2012   FAL             0025214: LCOL_C004-LCOL: Realizar desarrollo Comisiones Especiales negocio
     2.0        02/09/2019   ECP             IAXIS-4082.Convenio Grandes Beneficiarios - RCE Derivado de Contratos
   ******************************************************************************/
   e_object_error   EXCEPTION;
   e_param_error    EXCEPTION;

   /*************************************************************************
      Recupera la lista de los convenios de comisión especial en función de los parámetros recibidos
      param in pccodconv : identificador del convenio
      param in ptdesconv : descripción del convenio
      param in pfinivig  : fecha de inicio de vigencia del convenio
      param in pffinvig  : fecha de fin de vigencia del convenio
      param in psproduc  : código de producto
      param in pcagente  : código de agente
      param in ptnomtom  : nombre de tomador
      param in pcramo    : código de ramo
      return             : texto de la consulta
   *************************************************************************/
   FUNCTION f_get_lstconvcomesp (
      pccodconv   IN   NUMBER,
      ptdesconv   IN   VARCHAR2,
      pfinivig    IN   DATE,
      pffinvig    IN   DATE,
      psproduc    IN   NUMBER,
      pcagente    IN   NUMBER,
      ptnomtom    IN   VARCHAR2,
      pcramo      IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      vpas             NUMBER;
      vobj             VARCHAR2 (500)
                                  := 'pac_comisionegocio.f_get_lstconvcomesp';
      vpar             VARCHAR2 (500)
         :=    'c='
            || pccodconv
            || ' t='
            || ptdesconv
            || ' i='
            || pfinivig
            || ' f='
            || pffinvig
            || ' p='
            || psproduc
            || ' a='
            || pcagente
            || ' n='
            || ptnomtom
            || ' ramo='
            || pcramo;
      vquery           VARCHAR2 (2000);
      v_auxnom         VARCHAR2 (2000);
      num_err          NUMBER;
      v_ini            VARCHAR2 (20);
      v_fin            VARCHAR2 (20);
      --Ini IAXIS-4082 -- ECP -- 11/10/2019
      v_cpregun_2912   NUMBER          := 2912;
   --Fin IAXIS-4082 -- ECP -- 11/10/2019
   BEGIN
      vpas := 100;
      vquery :=
         'SELECT distinct(c.idconvcomesp),c.tdesconv,c.finivig,c.ffinvig FROM convcomisesp c where 1=1';

      IF pccodconv IS NOT NULL
      THEN
         vpas := 120;
         vquery := vquery || ' and IDCONVCOMESP=' || pccodconv;
      END IF;

      IF ptdesconv IS NOT NULL
      THEN
         vpas := 130;
         vquery :=
               vquery
            || ' and lower(TDESCONV) like '
            || CHR (39)
            || '%'
            || LOWER (ptdesconv)
            || '%'
            || CHR (39);
      END IF;

      IF pfinivig IS NOT NULL
      THEN
         vpas := 140;
         v_ini := TO_CHAR (pfinivig, 'yyyymmdd');
         vquery :=
               vquery
            || ' and FINIVIG >='
            || 'to_date('
            || CHR (39)
            || v_ini
            || CHR (39)
            || ',''yyyymmdd'')';
      END IF;

      IF pffinvig IS NOT NULL
      THEN
         vpas := 150;
         v_fin := TO_CHAR (pffinvig, 'yyyymmdd');
         vquery :=
               vquery
            || ' and FFINVIG <='
            || 'to_date('
            || CHR (39)
            || v_fin
            || CHR (39)
            || ',''yyyymmdd'')';
      END IF;

      IF psproduc IS NOT NULL
      THEN
         vpas := 170;
         vquery :=
               vquery
            || ' and exists (select 1 from CONVCOMESPPROD a'
            || ' where a.IDCONVCOMESP=c.IDCONVCOMESP and a.sproduc='
            || psproduc
            || ')';
      ELSE
         --RCL 25/06/2013 - BUG 27327 - Permitimos buscar por RAMO
         IF pcramo IS NOT NULL
         THEN
            vpas := 170;
            vquery :=
                  vquery
               || ' and exists (select 1 from CONVCOMESPPROD a'
               || ' where a.IDCONVCOMESP=c.IDCONVCOMESP and a.sproduc in (select sproduc from PRODUCTOS where cramo = '
               || pcramo
               || ') )';
         END IF;
      END IF;

      IF pcagente IS NOT NULL
      THEN
         vpas := 180;
         vquery :=
               vquery
            || ' and exists (select 1 from CONVCOMESPAGE a'
            || ' where a.IDCONVCOMESP=c.IDCONVCOMESP and a.CAGENTE='
            || pcagente
            || ')';
      END IF;

      IF ptnomtom IS NOT NULL
      THEN
         vpas := 190;
         num_err := f_strstd (ptnomtom, v_auxnom);
         vpas := 200;
         vquery :=
               vquery
            || ' and exists (select 1 from CONVCOMESPTOM a, PERSONAS b'
            || ' where a.IDCONVCOMESP=c.IDCONVCOMESP and b.sperson=a.sperson'
            || ' and upper(b.tbuscar) like upper(''%'
            || v_auxnom
            || '%'
            || CHR (39)
            || ')'
            || ')';
      END IF;

      vpas := 210;
      RETURN vquery;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobj,
                      vpas,
                      vpar,
                      SQLCODE || ' ' || SQLERRM
                     );
         RETURN NULL;
   END f_get_lstconvcomesp;

   /*************************************************************************
      Recupera los datos del convenio de comisión especial
      param in pccodconv : identificador del convenio
      return             : texto de la consulta
   *************************************************************************/
   FUNCTION f_get_datconvcomesp (pccodconv IN NUMBER)
      RETURN VARCHAR2
   IS
      vpas     NUMBER;
      vobj     VARCHAR2 (500)  := 'pac_comisionegocio.f_get_datconvcomesp';
      vpar     VARCHAR2 (500)  := 'i=' || pccodconv;
      vquery   VARCHAR2 (2000);
   BEGIN
      vpas := 100;

      IF pccodconv IS NULL
      THEN
         RAISE NO_DATA_FOUND;
      END IF;

      vpas := 110;
      vquery :=
            'SELECT distinct idconvcomesp,tdesconv,finivig,ffinvig FROM CONVCOMISESP c'
         || ' WHERE c.IDCONVCOMESP = '
         || pccodconv;
      RETURN vquery;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobj,
                      vpas,
                      vpar,
                      SQLCODE || ' ' || SQLERRM
                     );
         RETURN NULL;
   END f_get_datconvcomesp;

   /*************************************************************************
      Recupera los datos del producto del convenio de comisión especial
      param in pccodconv : identificador del convenio
      return             : texto de la consulta
   *************************************************************************/
   FUNCTION f_get_prodconvcomesp (pccodconv IN NUMBER)
      RETURN VARCHAR2
   IS
      vpas      NUMBER;
      vobj      VARCHAR2 (500)  := 'pac_comisionegocio.f_get_prodconvcomesp';
      vpar      VARCHAR2 (500)  := 'i=' || pccodconv;
      vquery    VARCHAR2 (2000);
      vidioma   NUMBER;
   BEGIN
      vpas := 100;

      IF pccodconv IS NULL
      THEN
         RAISE NO_DATA_FOUND;
      END IF;

      vidioma := f_usu_idioma;
      vpas := 110;
      vquery :=
            'SELECT c.IDCONVCOMESP, c.SPRODUC, a.ttitulo TPRODUC'
         || ' FROM CONVCOMESPPROD c, productos b, titulopro a'
         || ' WHERE c.IDCONVCOMESP = '
         || pccodconv
         || ' and   b.sproduc=c.sproduc'
         || ' and   a.cramo=b.cramo and a.cmodali=b.cmodali and a.ctipseg=b.ctipseg and a.ccolect=b.ccolect and a.cidioma=f_usu_idioma';
      RETURN vquery;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobj,
                      vpas,
                      vpar,
                      SQLCODE || ' ' || SQLERRM
                     );
         RETURN NULL;
   END f_get_prodconvcomesp;

   /*************************************************************************
      Recupera los datos del agente del convenio de comisión especial
      param in pccodconv : identificador del convenio
      return             : texto de la consulta
   *************************************************************************/
   FUNCTION f_get_ageconvcomesp (pccodconv IN NUMBER)
      RETURN VARCHAR2
   IS
      vpas     NUMBER;
      vobj     VARCHAR2 (500)  := 'pac_comisionegocio.f_get_ageconvcomesp';
      vpar     VARCHAR2 (500)  := 'i=' || pccodconv;
      vquery   VARCHAR2 (2000);
   BEGIN
      vpas := 100;

      IF pccodconv IS NULL
      THEN
         RAISE NO_DATA_FOUND;
      END IF;

      vpas := 110;
      vquery :=
            'SELECT c.*, F_NOMBRE(b.sperson, 3) TNOMAGE FROM CONVCOMESPAGE c, agentes b'
         || ' WHERE c.IDCONVCOMESP = '
         || pccodconv
         || ' and b.cagente=c.cagente';
      RETURN vquery;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobj,
                      vpas,
                      vpar,
                      SQLCODE || ' ' || SQLERRM
                     );
         RETURN NULL;
   END f_get_ageconvcomesp;

   /*************************************************************************
      Recupera los datos del tomador del convenio de comisión especial
      param in pccodconv : identificador del convenio
      return             : texto de la consulta
   *************************************************************************/
   FUNCTION f_get_tomconvcomesp (pccodconv IN NUMBER)
      RETURN VARCHAR2
   IS
      vpas     NUMBER;
      vobj     VARCHAR2 (500)  := 'pac_comisionegocio.f_get_tomconvcomesp';
      vpar     VARCHAR2 (500)  := 'i=' || pccodconv;
      vquery   VARCHAR2 (2000);
   BEGIN
      vpas := 100;

      IF pccodconv IS NULL
      THEN
         RAISE NO_DATA_FOUND;
      END IF;

      vpas := 110;
      vquery :=
            'SELECT c.*, F_NOMBRE(c.sperson, 3) TNOMTOM FROM CONVCOMESPTOM c'
         || ' WHERE c.IDCONVCOMESP = '
         || pccodconv;
      RETURN vquery;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobj,
                      vpas,
                      vpar,
                      SQLCODE || ' ' || SQLERRM
                     );
         RETURN NULL;
   END f_get_tomconvcomesp;

   /*************************************************************************
      Borra los el agente de un convenio de comisión especial
      param in pccodconv : identificador del convenio
      param in pcagente  : código de agente
      return             : 0 si está todo Ok y 1 si existe algún tipo de error
   *************************************************************************/
   FUNCTION f_del_ageconvcomesp (pccodconv IN NUMBER, pcagente IN NUMBER)
      RETURN NUMBER
   IS
      vpas      NUMBER;
      vobj      VARCHAR2 (500) := 'pac_comisionegocio.f_del_ageconvcomesp';
      vpar      VARCHAR2 (500) := 'i=' || pccodconv || ' a=' || pcagente;
      num_err   NUMBER;
   BEGIN
      num_err := 0;
      vpas := 100;

      IF pccodconv IS NULL OR pcagente IS NULL
      THEN
         RAISE NO_DATA_FOUND;
      END IF;

      vpas := 110;

      DELETE FROM convcomespage
            WHERE idconvcomesp = pccodconv AND cagente = pcagente;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobj,
                      vpas,
                      vpar,
                      SQLCODE || ' ' || SQLERRM
                     );
         RETURN 9904664;
   END f_del_ageconvcomesp;

   /*************************************************************************
      Borra el tomador de un convenio de comisión especial
      param in pccodconv : identificador del convenio
      param in psperson  : código del tomador
      return             : 0 si está todo Ok y 1 si existe algún tipo de error
   *************************************************************************/
   FUNCTION f_del_tomconvcomesp (pccodconv IN NUMBER, psperson IN NUMBER)
      RETURN NUMBER
   IS
      vpas      NUMBER;
      vobj      VARCHAR2 (500) := 'pac_comisionegocio.f_del_tomconvcomesp';
      vpar      VARCHAR2 (500) := 'i=' || pccodconv || ' p=' || psperson;
      num_err   NUMBER;
   BEGIN
      num_err := 0;
      vpas := 100;

      IF pccodconv IS NULL OR psperson IS NULL
      THEN
         RAISE NO_DATA_FOUND;
      END IF;

      vpas := 110;

      DELETE FROM convcomesptom
            WHERE idconvcomesp = pccodconv AND sperson = psperson;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobj,
                      vpas,
                      vpar,
                      SQLCODE || ' ' || SQLERRM
                     );
         RETURN 9904665;
   END f_del_tomconvcomesp;

   /*************************************************************************
      Actualiza/inserta los datos de un convenio de comisión especial
      param in pccodconv : identificador del convenio
      param in ptdesconv : descripción del convenio
      param in pfinivig  : fecha de inicio de vigencia del convenio
      param in pffinvig  : fecha de fin de vigencia del convenio
      param in pccomisi  : % de comisión especial del convenio
      param in pcusualt  : usuario de alta
      param out pccodconv_out  : identificador del nuevo convenio creado
      return             : 0 si está todo Ok y 1 si existe algún tipo de error
   *************************************************************************/
   FUNCTION f_set_datconvcomesp (
      pccodconv   IN   NUMBER,
      ptdesconv   IN   VARCHAR2,
      pfinivig    IN   DATE,
      pffinvig    IN   DATE,
      pccomisi    IN   FLOAT,
      pcmodcom    IN   NUMBER
   )
      RETURN NUMBER
   IS
      vpas      NUMBER;
      vobj      VARCHAR2 (500) := 'pac_comisionegocio.f_set_datconvcomesp';
      vpar      VARCHAR2 (500)
         :=    ' c='
            || pccodconv
            || ' t='
            || ptdesconv
            || ' i='
            || pfinivig
            || ' f='
            || pffinvig
            || ' pcomis='
            || pccomisi;
      num_err   NUMBER;
   BEGIN
      num_err := 0;
      vpas := 100;

      IF pffinvig IS NOT NULL AND pfinivig IS NOT NULL
      THEN
         IF pfinivig > pffinvig
         THEN
            -- La fecha de inicio no puede ser posterior a la fecha final
            RETURN 110361;
         END IF;
      END IF;

      IF pccomisi < 0 OR pccomisi >= 100
      THEN
         RETURN 9904621;                           --Porcentaje entre 0 y 100
      END IF;

      vpas := 120;

      BEGIN
         INSERT INTO convcomisesp
                     (idconvcomesp, tdesconv, cusualt, finivig, ffinvig,
                      pcomisi, cmodcom, falta
                     )
              VALUES (pccodconv, ptdesconv, f_user, pfinivig, pffinvig,
                      pccomisi, pcmodcom, f_sysdate
                     );
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            vpas := 130;

            UPDATE convcomisesp
               SET tdesconv = NVL (ptdesconv, tdesconv),
                   finivig = NVL (pfinivig, finivig),
                   ffinvig = NVL (pffinvig, ffinvig),
                   pcomisi = NVL (pccomisi, pcomisi)
             WHERE idconvcomesp = pccodconv AND cmodcom = pcmodcom;
      END;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobj,
                      vpas,
                      vpar,
                      SQLCODE || ' ' || SQLERRM
                     );
         RETURN 9904666;
   END f_set_datconvcomesp;

   FUNCTION f_get_next_conv
      RETURN NUMBER
   IS
      pccodconv_out   NUMBER;
   BEGIN
      SELECT NVL (MAX (idconvcomesp), 0) + 1
        INTO pccodconv_out
        FROM convcomisesp;

      RETURN pccodconv_out;
   END f_get_next_conv;

   /*************************************************************************
      Parametriza un producto como afectado por un convenio de comisión especial
      param in pccodconv : identificador del convenio
      param in psproduc  : código de producto
      return             : 0 si está todo Ok y 1 si existe algún tipo de error
   *************************************************************************/
   FUNCTION f_set_prodconvcomesp (pccodconv IN NUMBER, psproduc IN NUMBER)
      RETURN NUMBER
   IS
      vpas      NUMBER;
      vobj      VARCHAR2 (500) := 'pac_comisionegocio.f_set_prodconvcomesp';
      vpar      VARCHAR2 (500) := 'i=' || pccodconv || ' p=' || psproduc;
      num_err   NUMBER;
   BEGIN
      num_err := 0;
      vpas := 100;

      BEGIN
         INSERT INTO convcomespprod
                     (idconvcomesp, sproduc
                     )
              VALUES (pccodconv, psproduc
                     );
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            -- num_err := 9904669;
            UPDATE convcomespprod
               SET sproduc = psproduc
             WHERE idconvcomesp = pccodconv;
      END;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobj,
                      vpas,
                      vpar,
                      SQLCODE || ' ' || SQLERRM
                     );
         RETURN 9904667;
   END f_set_prodconvcomesp;

   /*************************************************************************
      Parametriza un agente como afectado por un convenio de comisión especial
      param in pccodconv : identificador del convenio
      param in pcagente  : código de agente
      return             : 0 si está todo Ok y 1 si existe algún tipo de error
   *************************************************************************/
   FUNCTION f_set_ageconvcomesp (pccodconv IN NUMBER, pcagente IN NUMBER)
      RETURN NUMBER
   IS
      vpas      NUMBER;
      vobj      VARCHAR2 (500) := 'pac_comisionegocio.f_set_ageconvcomesp';
      vpar      VARCHAR2 (500) := 'i=' || pccodconv || ' a=' || pcagente;
      num_err   NUMBER;
      vcount    NUMBER;
   BEGIN
      num_err := 0;
      vpas := 100;

      SELECT COUNT (1)
        INTO vcount
        FROM convcomespage
       WHERE idconvcomesp = pccodconv;

      vpas := 101;

      IF vcount = 1
      THEN
         DELETE      convcomespage
               WHERE idconvcomesp = pccodconv;
      END IF;

      vpas := 102;

      BEGIN
         INSERT INTO convcomespage
                     (idconvcomesp, cagente
                     )
              VALUES (pccodconv, pcagente
                     );
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            UPDATE convcomespage
               SET cagente = pcagente
             WHERE idconvcomesp = pccodconv;
      END;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobj,
                      vpas,
                      vpar,
                      SQLCODE || ' ' || SQLERRM
                     );
         RETURN 9904668;
   END f_set_ageconvcomesp;

  /*************************************************************************
      Parametriza un tomador como afectado por un convenio de comisin especial
      param in pccodconv : identificador del convenio
      param in psperson  : cdigo del tomador
      return             : 0 si est todo Ok y 1 si existe algn tipo de error
   *************************************************************************/
   FUNCTION f_set_tomconvcomesp (pccodconv IN NUMBER, psperson IN NUMBER)
      RETURN NUMBER
   IS
      vpas      NUMBER;
      vobj      VARCHAR2 (500) := 'pac_comisionegocio.f_set_tomconvcomesp';
      vpar      VARCHAR2 (500) := 'i=' || pccodconv || ' s=' || psperson;
      num_err   NUMBER;
      vcount    NUMBER;
   BEGIN
      num_err := 0;

      BEGIN
         vpas := 100;

         INSERT INTO convcomesptom
                     (idconvcomesp, sperson
                     )
              VALUES (pccodconv, psperson
                     );
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            -- num_err := 9904671;
            UPDATE convcomesptom
               SET sperson = psperson
             WHERE idconvcomesp = pccodconv AND sperson = psperson;
      END;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobj,
                      vpas,
                      vpar,
                      SQLCODE || ' ' || SQLERRM
                     );
         RETURN 9904672;
   END f_set_tomconvcomesp;

  /*************************************************************************
      Valida la creacin/modificacin de un convenio
      param in pccodconv : identificador del convenio
      param in pfinivig  : fecha de inicio de vigencia del convenio
      param in pffinvig  : fecha de fin de vigencia del convenio
      param in plistaprods : coleccin de productos que intervienen en el convenio
      param in pcagente  : % de comisin especial del convenio
      param in psperson  : sperson del tomador que interviene en el convenio
      param in pprimausd  : prima en USD
      param in pprimaeur  : prima en EUR
      return            : 0 si est todo Ok y 1 si existe algn tipo de error
   *************************************************************************/
   FUNCTION f_valida_creaconv (
      pccodconv     IN   NUMBER,
      pfinivig      IN   DATE,
      pffinvig      IN   DATE,
      plistaprods   IN   t_iax_info,
      pcagente      IN   NUMBER,
      psperson      IN   NUMBER,
      pprimausd     IN   NUMBER,
      pprimaeur     IN   NUMBER
   )
      RETURN NUMBER
   IS
      v_existconv             NUMBER := 0;
      v_existconvprod         NUMBER := 0;
      v_existconvfechasolap   NUMBER := 0;
      v_esalta                NUMBER;
      v_nuevo_conv            NUMBER := 0;
      v_nuevo_aseg            NUMBER := 0;  
      v_divisa_prod           NUMBER := 0;
   BEGIN
   
     --INI IAXIS 4081 AABG: Validacion de existencia de asegurado en algun convenio
     SELECT COUNT(*) INTO v_nuevo_conv FROM convcomesptom WHERE IDCONVCOMESP = pccodconv;
     IF v_nuevo_conv <= 0 THEN
        --CONVENIO NUEVO
        SELECT COUNT(*) INTO v_nuevo_aseg FROM convcomesptom WHERE SPERSON = psperson;
        IF v_nuevo_aseg > 0 THEN
            RETURN 89907079;
        END IF;
     ELSE
        --CONVENIO ACTUALIZAR
        SELECT COUNT(*) INTO v_nuevo_aseg FROM convcomesptom WHERE SPERSON = psperson AND IDCONVCOMESP != pccodconv;
        IF v_nuevo_aseg > 0 THEN
            RETURN 89907079;
        END IF;
     END IF;
     --FIN IAXIS 4081 AABG: Validacion de existencia de asegurado en algun convenio
     
     --INI IAXIS 4081 AABG: Validacion de primas para USD y EUR
       IF plistaprods IS NULL
       THEN
          RETURN 9904679;
       END IF;
       IF plistaprods.COUNT = 0
       THEN
          RETURN 9904679;
       END IF;
       FOR j IN plistaprods.FIRST .. plistaprods.LAST
       LOOP
       
        SELECT CDIVISA INTO v_divisa_prod FROM PRODUCTOS WHERE SPRODUC = plistaprods (j).valor_columna;
        
         IF v_divisa_prod = 6 AND (pprimausd IS NULL OR pprimausd <= 0) THEN
            RETURN 89907082;
         END IF;
         IF v_divisa_prod = 1 AND (pprimaeur IS NULL OR pprimaeur <= 0) THEN
            RETURN 89907083;
         END IF;
       END LOOP;
     --FIN IAXIS 4081 AABG: Validacion de primas para USD y EUR
   
      --RCL 25/06/2013 - BUG 27327 - Validamos pcagente
      IF pcagente IS NULL
      THEN
         RETURN 9904590;                         -- Falta informar un agente.
      END IF;

      --JLV Determinar si es un alta o una modificacin.
      IF pccodconv IS NULL
      THEN
         v_esalta := 0;
      ELSE
         SELECT COUNT (1)
           INTO v_esalta
           FROM convcomisesp
          WHERE idconvcomesp = pccodconv;
      END IF;

      IF v_esalta = 0
      THEN
         IF psperson IS NOT NULL
         THEN
            SELECT COUNT (DISTINCT c.idconvcomesp)
              INTO v_existconv
              FROM convcomespage a, convcomesptom t, convcomisesp c
             WHERE a.cagente = pcagente
               AND t.idconvcomesp = a.idconvcomesp
               AND t.sperson = psperson
               AND t.idconvcomesp = c.idconvcomesp
               AND (   (    TRUNC (pfinivig) IS NOT NULL
                        AND TRUNC (c.ffinvig) IS NULL
                        AND TRUNC (pffinvig) IS NULL
                       )
                    OR (TRUNC (pfinivig) BETWEEN TRUNC (c.finivig)
                                             AND TRUNC (c.ffinvig)
                       )
                    OR (TRUNC (pffinvig) BETWEEN TRUNC (c.finivig)
                                             AND TRUNC (c.ffinvig)
                       )
                   );

            --AND(TRUNC(pfinivig) = TRUNC(c.finivig)
             --   OR TRUNC(pfinivig) BETWEEN TRUNC(c.finivig) AND TRUNC(c.ffinvig));
            IF v_existconv = 0
            THEN             -- No hay convenio definido para agente y tomador
               RETURN 0;
            ELSE
               IF plistaprods IS NULL
               THEN
                  RETURN 9904679;
-- Debe definirse como mnimo un producto en el convenio de comisin especial
               END IF;

               IF plistaprods.COUNT = 0
               THEN
                  RETURN 9904679;
               END IF;

               IF NVL
                     (pac_parametros.f_parempresa_n
                                           (pac_md_common.f_get_cxtempresa (),
                                            'NOVAL_SPERS_CREACONV'
                                           ),
                      0
                     ) = 0
               THEN
                  FOR j IN plistaprods.FIRST .. plistaprods.LAST
                  LOOP
                     IF plistaprods (j).seleccionado = 1
                     THEN
                        v_existconvprod := 0;

                        SELECT COUNT (1)
                          INTO v_existconvprod
                          FROM convcomespage a,
                               convcomesptom t,
                               convcomespprod p,
                               convcomisesp c
                         WHERE a.cagente = pcagente
                           AND t.idconvcomesp = a.idconvcomesp
                           AND t.sperson = psperson
                           AND p.sproduc = plistaprods (j).valor_columna
                           AND a.idconvcomesp = p.idconvcomesp
                           AND p.idconvcomesp = c.idconvcomesp
                           AND (   (    TRUNC (pfinivig) IS NOT NULL
                                    AND TRUNC (c.ffinvig) IS NULL
                                    AND TRUNC (pffinvig) IS NULL
                                   )
                                OR (TRUNC (pfinivig) BETWEEN TRUNC (c.finivig)
                                                         AND TRUNC (c.ffinvig)
                                   )
                                OR (TRUNC (pffinvig) BETWEEN TRUNC (c.finivig)
                                                         AND TRUNC (c.ffinvig)
                                   )
                               );

                        --AND(TRUNC(pfinivig) = TRUNC(c.finivig)
                        --    OR TRUNC(pfinivig) BETWEEN TRUNC(c.finivig) AND TRUNC(c.ffinvig));
                        IF v_existconvprod > 0
                        THEN
                           RETURN 9904680;
-- No se puede crear el convenio. Ya existe un convenio de comisin especial para el intermediario, tomador y producto seleccionado.
                        END IF;
                     END IF;
                  END LOOP;
               END IF;
            END IF;
         ELSE                                                 -- psperson NULO
            IF plistaprods IS NULL
            THEN
               RETURN 9904679;
-- Debe definirse como mnimo un producto en el convenio de comisin especial
            END IF;

            IF plistaprods.COUNT = 0
            THEN
               RETURN 9904679;
            END IF;

            IF NVL
                  (pac_parametros.f_parempresa_n
                                           (pac_md_common.f_get_cxtempresa (),
                                            'NOVAL_SPERS_CREACONV'
                                           ),
                   0
                  ) = 0
            THEN
               FOR j IN plistaprods.FIRST .. plistaprods.LAST
               LOOP
                  IF plistaprods (j).seleccionado = 1
                  THEN
                     v_existconvprod := 0;

                     SELECT COUNT (1)
                       INTO v_existconvprod
                       FROM convcomespage a, convcomespprod p, convcomisesp c
                      WHERE a.cagente = pcagente
                        AND p.sproduc = plistaprods (j).valor_columna
                        AND a.idconvcomesp = p.idconvcomesp
                        AND p.idconvcomesp = c.idconvcomesp
                        AND (   (    TRUNC (pfinivig) IS NOT NULL
                                 AND TRUNC (c.ffinvig) IS NULL
                                 AND TRUNC (pffinvig) IS NULL
                                )
                             OR (TRUNC (pfinivig) BETWEEN TRUNC (c.finivig)
                                                      AND TRUNC (c.ffinvig)
                                )
                             OR (TRUNC (pffinvig) BETWEEN TRUNC (c.finivig)
                                                      AND TRUNC (c.ffinvig)
                                )
                            )
                        --AND(TRUNC(pfinivig) = TRUNC(c.finivig)
                        --    OR TRUNC(pfinivig) BETWEEN TRUNC(c.finivig) AND TRUNC(c.ffinvig))
                        AND NOT EXISTS (SELECT 1
                                          FROM convcomesptom
                                         WHERE idconvcomesp = c.idconvcomesp);

                     IF v_existconvprod > 0
                     THEN
                        RETURN 9904681;
-- No se puede crear el convenio. Ya existe un convenio de comisin especial para el intermediario y producto seleccionado.
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         END IF;
      ELSE   -- Modificacion. Se valida la actualizacin de datos del convenio
         IF psperson IS NOT NULL
         THEN
            SELECT COUNT (DISTINCT c.idconvcomesp)
              INTO v_existconv
              FROM convcomespage a, convcomesptom t, convcomisesp c
             WHERE a.cagente = pcagente
               AND t.idconvcomesp = a.idconvcomesp
               AND t.sperson = psperson
               AND t.idconvcomesp = c.idconvcomesp
               AND (   (    TRUNC (pfinivig) IS NOT NULL
                        AND TRUNC (c.ffinvig) IS NULL
                        AND TRUNC (pffinvig) IS NULL
                       )
                    OR (TRUNC (pfinivig) BETWEEN TRUNC (c.finivig)
                                             AND TRUNC (c.ffinvig)
                       )
                    OR (TRUNC (pffinvig) BETWEEN TRUNC (c.finivig)
                                             AND TRUNC (c.ffinvig)
                       )
                   )
               -- AND(TRUNC(pfinivig) = TRUNC(c.finivig)
                --    OR TRUNC(pfinivig) BETWEEN TRUNC(c.finivig) AND TRUNC(c.ffinvig))
               AND a.idconvcomesp <> pccodconv;

            IF v_existconv = 0
            THEN             -- No hay convenio definido para agente y tomador
               SELECT COUNT (DISTINCT c.idconvcomesp)
                 INTO v_existconvfechasolap
                 FROM convcomespage a, convcomesptom t, convcomisesp c
                WHERE a.cagente = pcagente
                  AND t.idconvcomesp = a.idconvcomesp
                  AND t.sperson = psperson
                  AND t.idconvcomesp = c.idconvcomesp
                  AND (   TRUNC (pfinivig) = TRUNC (c.finivig)
                       OR TRUNC (pfinivig) BETWEEN TRUNC (c.finivig)
                                               AND TRUNC (c.ffinvig)
                       OR (    TRUNC (pffinvig) >= TRUNC (c.finivig)
                           AND pffinvig IS NOT NULL
                           AND c.ffinvig IS NULL
                          )
                      )
                  AND a.idconvcomesp <> pccodconv;

               IF v_existconvfechasolap > 0
               THEN
                  RETURN 9904686;
-- La fecha fin de vigencia del convenio debe ser menor a la fecha inicio vigencia de otro convenio existente con mismo agente y tomador.
               ELSE
                  RETURN 0;
               END IF;
            ELSE
               IF plistaprods IS NULL
               THEN
                  RETURN 9904679;
-- Debe definirse como mnimo un producto en el convenio de comisin especial
               END IF;

               IF plistaprods.COUNT = 0
               THEN
                  RETURN 9904679;
               END IF;

               IF NVL
                     (pac_parametros.f_parempresa_n
                                           (pac_md_common.f_get_cxtempresa (),
                                            'NOVAL_SPERS_CREACONV'
                                           ),
                      0
                     ) = 0
               THEN
                  FOR j IN plistaprods.FIRST .. plistaprods.LAST
                  LOOP
                     IF plistaprods (j).seleccionado = 1
                     THEN
                        v_existconvprod := 0;

                        SELECT COUNT (1)
                          INTO v_existconvprod
                          FROM convcomespage a,
                               convcomesptom t,
                               convcomespprod p,
                               convcomisesp c
                         WHERE a.cagente = pcagente
                           AND t.idconvcomesp = a.idconvcomesp
                           AND t.sperson = psperson
                           AND p.sproduc = plistaprods (j).valor_columna
                           AND t.idconvcomesp = p.idconvcomesp
                           AND p.idconvcomesp = c.idconvcomesp
                           AND a.idconvcomesp <> pccodconv
                           AND (   (    TRUNC (pfinivig) IS NOT NULL
                                    AND TRUNC (c.ffinvig) IS NULL
                                    AND TRUNC (pffinvig) IS NULL
                                   )
                                OR (TRUNC (pfinivig) BETWEEN TRUNC (c.finivig)
                                                         AND TRUNC (c.ffinvig)
                                   )
                                OR (TRUNC (pffinvig) BETWEEN TRUNC (c.finivig)
                                                         AND TRUNC (c.ffinvig)
                                   )
                               );

                        --AND(TRUNC(pfinivig) = TRUNC(c.finivig)
                        --    OR TRUNC(pfinivig) BETWEEN TRUNC(c.finivig) AND TRUNC(c.ffinvig));
                        IF v_existconvprod > 0
                        THEN
                           RETURN 9904682;
-- No se puede modificar el convenio. Ya existe un convenio de comisin especial para el intermediario, tomador y producto seleccionado.
                        ELSE
                           SELECT COUNT (1)
                             INTO v_existconvfechasolap
                             FROM convcomespage a,
                                  convcomesptom t,
                                  convcomespprod p,
                                  convcomisesp c
                            WHERE a.cagente = pcagente
                              AND t.idconvcomesp = a.idconvcomesp
                              AND t.sperson = psperson
                              AND p.sproduc = plistaprods (j).valor_columna
                              AND t.idconvcomesp = p.idconvcomesp
                              AND p.idconvcomesp = c.idconvcomesp
                              AND a.idconvcomesp <> pccodconv
                              AND (   TRUNC (pfinivig) = TRUNC (c.finivig)
                                   OR TRUNC (pfinivig) BETWEEN TRUNC
                                                                    (c.finivig)
                                                           AND TRUNC
                                                                    (c.ffinvig)
                                   OR (    TRUNC (pffinvig) >=
                                                             TRUNC (c.finivig)
                                       AND pffinvig IS NOT NULL
                                       AND c.ffinvig IS NULL
                                      )
                                  );

                           IF v_existconvfechasolap > 0
                           THEN
                              RETURN 9904689;
-- La fecha fin de vigencia del convenio debe ser menor a la fecha inicio vigencia de otro convenio existente con mismo agente, tomador y producto.
                           END IF;
                        END IF;
                     END IF;
                  END LOOP;
               END IF;
            END IF;
         ELSE                                                 -- psperson NULO
            IF plistaprods IS NULL
            THEN
               RETURN 9904679;
-- Debe definirse como mnimo un producto en el convenio de comisin especial
            END IF;

            IF plistaprods.COUNT = 0
            THEN
               RETURN 9904679;
            END IF;

            IF NVL
                  (pac_parametros.f_parempresa_n
                                           (pac_md_common.f_get_cxtempresa (),
                                            'NOVAL_SPERS_CREACONV'
                                           ),
                   0
                  ) = 0
            THEN
               FOR j IN plistaprods.FIRST .. plistaprods.LAST
               LOOP
                  IF plistaprods (j).seleccionado = 1
                  THEN
                     v_existconvprod := 0;

                     SELECT COUNT (1)
                       INTO v_existconvprod
                       FROM convcomespage a, convcomespprod p, convcomisesp c
                      WHERE a.cagente = pcagente
                        AND p.sproduc = plistaprods (j).valor_columna
                        AND a.idconvcomesp = p.idconvcomesp
                        AND a.idconvcomesp <> pccodconv
                        AND p.idconvcomesp = c.idconvcomesp
                        AND (   (    TRUNC (pfinivig) IS NOT NULL
                                 AND TRUNC (c.ffinvig) IS NULL
                                 AND TRUNC (pffinvig) IS NULL
                                )
                             OR (TRUNC (pfinivig) BETWEEN TRUNC (c.finivig)
                                                      AND TRUNC (c.ffinvig)
                                )
                             OR (TRUNC (pffinvig) BETWEEN TRUNC (c.finivig)
                                                      AND TRUNC (c.ffinvig)
                                )
                            )
                        --AND(TRUNC(pfinivig) <= TRUNC(c.finivig)
                        --    OR TRUNC(pfinivig) BETWEEN TRUNC(c.finivig) AND TRUNC(c.ffinvig))
                        AND NOT EXISTS (SELECT 1
                                          FROM convcomesptom
                                         WHERE idconvcomesp = c.idconvcomesp);

                     IF v_existconvprod > 0
                     THEN
                        RETURN 9904683;
-- No se puede modificar el convenio. Ya existe un convenio de comisin especial para el intermediario y producto seleccionado.
                     ELSE
                        SELECT COUNT (1)
                          INTO v_existconvfechasolap
                          FROM convcomespage a,
                               convcomespprod p,
                               convcomisesp c
                         WHERE a.cagente = pcagente
                           AND p.sproduc = plistaprods (j).valor_columna
                           AND a.idconvcomesp = p.idconvcomesp
                           AND a.idconvcomesp <> pccodconv
                           AND p.idconvcomesp = c.idconvcomesp
                           AND (   TRUNC (pfinivig) = TRUNC (c.finivig)
                                OR TRUNC (pfinivig) BETWEEN TRUNC (c.finivig)
                                                        AND TRUNC (c.ffinvig)
                                OR (    TRUNC (pffinvig) >= TRUNC (c.finivig)
                                    AND pffinvig IS NOT NULL
                                    AND c.ffinvig IS NULL
                                   )
                               )
                           AND NOT EXISTS (
                                           SELECT 1
                                             FROM convcomesptom
                                            WHERE idconvcomesp =
                                                                c.idconvcomesp);

                        IF v_existconvfechasolap > 0
                        THEN
                           RETURN 9904688;
-- La fecha fin de vigencia del convenio debe ser menor a la fecha inicio vigencia de otro convenio existente con mismo agente y producto.
                        END IF;
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   END f_valida_creaconv;

/*
   FUNCTION f_set_porcenconvcomesp(
      pccodconv IN NUMBER,
      pcmodcom IN NUMBER,
      ppcomisi IN FLOAT)
      RETURN NUMBER IS

    BEGIN
        UPDATE convcomisesp
        set pcomisi = ppcomisi
        where IDCONVCOMESP = pccodconv AND
              cmodcom = pcmodcom;

        RETURN 0;
    END f_set_porcenconvcomesp;
*/

   /*************************************************************************
       Nos devuelve si un tomador o agente tiene parametrizado un convenio
       param in pspersonton : identificador del tomador
       param in pcagente    : identificador del agente
       param in pfefecto    : fecha de efecto de la poliza
       param out pconvenio  : 0 - no tiene conveno parametrizado 1 - Si
       return             : Codigo de error

       Bug 27327/146916 - 27/06/2013 - AMC
    *************************************************************************/
   FUNCTION f_get_tieneconvcomesp (
      pspersonton   IN       NUMBER,
      pcagente      IN       NUMBER,
      psproduc      IN       NUMBER,
      pfefecto      IN       DATE,
      pconvenio     OUT      NUMBER
   )
      RETURN NUMBER
   IS
      vpas             NUMBER;
      vobj             VARCHAR2 (500)
                                := 'pac_comisionegocio.f_get_tieneconvcomesp';
      vpar             VARCHAR2 (500)
                 := 'pspersonton=' || pspersonton || ' pcagente=' || pcagente;
      vcount           NUMBER;
      vriesgos         t_iax_riesgos;
      aseg             t_iax_asegurados;
      mensajes         t_iax_mensajes;
      v_pspersonton    NUMBER;
      --Ini IAXIS-4082 -- ECP  -- 11/10/2019
      v_cpregun_2912   NUMBER           := 2912;
      v_nnumide        VARCHAR2 (30);
   --Fin IAXIS-4082 -- ECP  -- 11/10/2019
   BEGIN
      vpas := 100;

      IF pspersonton IS NULL AND pcagente IS NULL AND psproduc IS NULL
      THEN
         RAISE NO_DATA_FOUND;
      END IF;

      IF NVL
            (pac_mdpar_productos.f_get_parproducto
                                 ('CONVENIO_TOMADOR',
                                  pac_iax_produccion.poliza.det_poliza.sproduc
                                 ),
             0
            ) = 1
      THEN
         vriesgos :=
            pac_iobj_prod.f_partpolriesgos
                                       (pac_iax_produccion.poliza.det_poliza,
                                        mensajes
                                       );

         IF vriesgos IS NOT NULL
         THEN
            IF vriesgos.COUNT > 0
            THEN
               FOR vrie IN vriesgos.FIRST .. vriesgos.LAST
               LOOP
                  IF vriesgos.EXISTS (vrie)
                  THEN
                     aseg :=
                        pac_iobj_prod.f_partriesasegurado (vriesgos (vrie),
                                                           mensajes
                                                          );

                     IF aseg IS NOT NULL
                     THEN
                        IF aseg.COUNT > 0
                        THEN
                           FOR vaseg IN aseg.FIRST .. aseg.LAST
                           LOOP
                              IF aseg.EXISTS (vaseg)
                              THEN
                                 v_pspersonton := aseg (vaseg).spereal;
                              END IF;
                           END LOOP;
                        END IF;
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         END IF;
      ELSE
         -- Ini IAXIS-4082 -- ECP -- 02/09/2019
        
         IF NVL
               (pac_mdpar_productos.f_get_parproducto
                                 ('CONV_CONTRATANTE',
                                  pac_iax_produccion.poliza.det_poliza.sproduc
                                 ),
                0
               ) = 1
         THEN
            --Ini IAXIS-4082 -- ECP -- 11/10/2019
            IF pac_iax_produccion.poliza.det_poliza.preguntas IS NOT NULL
            THEN
               IF pac_iax_produccion.poliza.det_poliza.preguntas.COUNT > 0
               THEN
                  FOR i IN
                     pac_iax_produccion.poliza.det_poliza.preguntas.FIRST .. pac_iax_produccion.poliza.det_poliza.preguntas.LAST
                  LOOP
                     IF v_cpregun_2912 =
                           pac_iax_produccion.poliza.det_poliza.preguntas (i).cpregun
                     THEN
                        v_nnumide :=
                           pac_iax_produccion.poliza.det_poliza.preguntas (i).trespue;
                     END IF;
                  END LOOP;
               END IF;
            END IF;

            BEGIN
               SELECT sperson
                 INTO v_pspersonton
                 FROM per_identificador
                WHERE nnumide = v_nnumide;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  v_pspersonton := pspersonton;
            END;
         --Fin IAXIS-4082 -- ECP -- 11/10/2019
         END IF;
      END IF;

      --Fin iAXIS-4082 -- ECP --02/09/2019
      vpas := 110;
     

      IF v_pspersonton IS NOT NULL
      THEN
         SELECT COUNT (1)
           INTO vcount
           FROM convcomesptom t,
                convcomespprod p,
                convcomespage a,
                convcomisesp e
          WHERE a.idconvcomesp = t.idconvcomesp
            AND a.idconvcomesp = p.idconvcomesp
            AND a.idconvcomesp = e.idconvcomesp
            AND t.sperson = v_pspersonton
            AND p.sproduc = psproduc
            AND a.cagente = pcagente
            AND NVL (pfefecto, f_sysdate) BETWEEN e.finivig
                                              AND NVL (e.ffinvig, f_sysdate);

         IF vcount > 0
         THEN
            pconvenio := 1;
            RETURN 0;
         END IF;
      END IF;

      IF pcagente IS NOT NULL
      THEN
         SELECT COUNT (1)
           INTO vcount
           FROM convcomespage a, convcomespprod p, convcomisesp e
          WHERE a.idconvcomesp = p.idconvcomesp
            AND a.idconvcomesp = e.idconvcomesp
            AND a.cagente = pcagente
            AND p.sproduc = psproduc
            AND NVL (pfefecto, f_sysdate) BETWEEN e.finivig
                                              AND NVL (e.ffinvig, f_sysdate)
            AND a.idconvcomesp NOT IN (SELECT idconvcomesp
                                         FROM convcomesptom);

         IF vcount > 0
         THEN
            pconvenio := 1;
            RETURN 0;
         END IF;
      END IF;

     
      pconvenio := 0;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobj,
                      vpas,
                      vpar,
                      SQLCODE || ' ' || SQLERRM
                     );
         RETURN 1;
   END f_get_tieneconvcomesp;
   
/*************************************************************************
      Parametriza un tomador como afectado por un convenio de comisión especial en la tabla SGT
      param in psproduc : identificador del producto
      param in pnnumide  : Numero identificacion del tomador
      return             : 0 si está todo Ok y 1 si existe algún tipo de error
   *************************************************************************/
   FUNCTION f_set_subtabsdet(psproduc IN NUMBER, pnnumide IN NUMBER, ptasa IN NUMBER, pprima IN NUMBER, pcodconv IN NUMBER, pcodgarantia IN NUMBER)
      RETURN NUMBER
   IS
      vpas      NUMBER;
      vobj      VARCHAR2 (500) := 'pac_comisionegocio.f_set_subtabsdet';
      vpar      VARCHAR2 (500) := 'i=' || psproduc || ' s=' || pnnumide;
      num_err   NUMBER;
      vcount    NUMBER;
      vnextval NUMBER;
   BEGIN
      num_err := 0;
         vpas := 100; 
         SELECT MAX(SDETALLE) + 1 INTO vnextval FROM SGT_SUBTABS_DET;
          INSERT INTO SGT_SUBTABS_DET(SDETALLE, CEMPRES, CSUBTABLA, CVERSUBT, CCLA1, CCLA2, CCLA3, CCLA4, CCLA5, NVAL1, NVAL2, FALTA, CUSUALT)
            VALUES(/*SGTSUBTABSDES.NEXTVAL*/vnextval, pac_md_common.f_get_cxtempresa(), 9000007, 1, psproduc, 1, pnnumide, pcodgarantia, pcodconv, ptasa, pprima, f_sysdate , f_user);
            
      RETURN num_err;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobj,
                      vpas,
                      vpar,
                      SQLCODE || ' ' || SQLERRM
                     );
         RETURN 89907084;
   END f_set_subtabsdet;   
   
 /*************************************************************************
      Obtiene la tasa o prima de un producto para un asegurado
      param in pccodconv : identificador del convenio
      param in pcnnumide  : numero identificacion asegurado
      param in pccodproducto : identificador del producto
      param in pcopcion  : opcion a consultar (1-> Tasa, 2-> Prima)
      return             : 0 si está todo Ok y 1 si existe algún tipo de error
   *************************************************************************/
   FUNCTION f_get_tasa_prima(pccodconv IN NUMBER, pcnnumide IN NUMBER, pccodproducto IN NUMBER, pcopcion IN NUMBER, pccodgarantia IN NUMBER)
      RETURN NUMBER
   IS
      vpas      NUMBER;
      vobj      VARCHAR2 (500) := 'pac_comisionegocio.f_get_tasa_prima';
      vpar      VARCHAR2 (500) := 'i=' || pccodconv || ' a=' || pcnnumide || 'c=' || pccodproducto || ' d=' || pcopcion;
      num_err   NUMBER;
   BEGIN
      num_err := -1;
      vpas := 100;

      IF pccodconv IS NULL OR pcnnumide IS NULL OR pccodproducto IS NULL
      THEN
         RAISE NO_DATA_FOUND;
      END IF;

      vpas := 110;

        IF pcopcion = 1 THEN
            SELECT DISTINCT(NVAL1) INTO num_err
            FROM SGT_SUBTABS_DET
            WHERE CCLA5 = pccodconv AND CCLA1 = pccodproducto AND CCLA4 = pccodgarantia;
        ELSE
             BEGIN
             IF pcopcion = 2 THEN
                SELECT PPRIMA INTO num_err
                FROM CONVPRIM
                WHERE IDCONVCOMESP = pccodconv;
             ELSIF pcopcion = 3 THEN  
                SELECT PPRIMAUSD INTO num_err
                FROM CONVPRIM
                WHERE IDCONVCOMESP = pccodconv;
             ELSE
                SELECT PPRIMAEUR INTO num_err
                FROM CONVPRIM
                WHERE IDCONVCOMESP = pccodconv;
             END IF;                
             EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    RETURN -1;
             END;
        END IF;
      

      RETURN num_err;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
      p_tab_error (f_sysdate,
                      f_user,
                      vobj,
                      vpas,
                      vpar,
                      SQLCODE || ' ' || SQLERRM
                     );
         RETURN -1;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobj,
                      vpas,
                      vpar,
                      SQLCODE || ' ' || SQLERRM
                     );
         RETURN 9904664;
   END f_get_tasa_prima;   
   
       /*************************************************************************
      Funcion para gurdar la prima normal, en USD y EUR de un convenio
      param in pccodconv : identificador del convenio
      param in pprima  : prima del convenio
      param in pprimausd : prima del convenio en moneda USD
      param in pprimaeur  : prima del convenio en moneda EUR
      return             : 0 si está todo Ok y 1 si existe algún tipo de error
   *************************************************************************/
   FUNCTION f_set_convprima(pccodconv IN NUMBER, pprima IN NUMBER, pprimausd IN NUMBER, pprimaeur IN NUMBER)
      RETURN NUMBER
   IS
      vpas      NUMBER;
      vobj      VARCHAR2 (500) := 'pac_comisionegocio.f_set_convprima';
      vpar      VARCHAR2 (500) := 'i=' || pccodconv || ' a=' || pprima || 'c=' || pprimausd || ' d=' || pprimaeur;
      num_err   NUMBER;
   BEGIN
      num_err := 0;
      vpas := 100;

      IF pccodconv IS NULL OR pprima IS NULL
      THEN
         RAISE NO_DATA_FOUND;
      END IF;

      vpas := 110;
        
      DELETE FROM CONVPRIM WHERE IDCONVCOMESP = pccodconv;
             
      INSERT INTO CONVPRIM(IDCONVCOMESP, PPRIMA, PPRIMAUSD, PPRIMAEUR)
      VALUES(pccodconv, pprima, pprimausd, pprimaeur);

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobj,
                      vpas,
                      vpar,
                      SQLCODE || ' ' || SQLERRM
                     );
         RETURN 89907085;
   END f_set_convprima;   
   
END pac_comisionegocio;
/