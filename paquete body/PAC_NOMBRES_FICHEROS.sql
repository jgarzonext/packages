--------------------------------------------------------
--  DDL for Package Body PAC_NOMBRES_FICHEROS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_NOMBRES_FICHEROS" IS
   /****************************************************************************
        NOMBRE:     PAC_NOMBRES_FICHEROS
        PROPÓSITO:  Cuerpo del paquete de las funciones para el nombramiento de ficheros

        REVISIONES:
        Ver        Fecha        Autor             Descripción
        ---------  ----------  ---------------  ----------------------------------
        1          17/03/2010   FAL             1.Creación
        2.0        14/11/2011   JMF             2. 0019999: LCOL_A001-Domis - Generacion de los diferentes formatos de fichero
        3.0        17/07/2014   dlF             3. 0028661: IAX998-Implementar SEPA en iAxis
     ****************************************************************************/
   PROCEDURE p_param_pacnombresficheros(
      p_nompac IN OUT VARCHAR2,
      p_auxpar IN OUT VARCHAR2,
      p_ctipcob IN NUMBER) IS
   -- p_nompac : resultado nombre package
   -- p_auxpar : resultado auxiliar parametros
   -- p_ctipcob: parametro tipo cobro
   BEGIN
      IF INSTR(p_nompac, '|pctipban') > 0 THEN
         IF p_ctipcob IS NOT NULL THEN
            p_auxpar := p_auxpar || ', ' || p_ctipcob;
         END IF;

         p_nompac := REPLACE(p_nompac, '|pctipban', '');
      END IF;
   END;

   -- BUG 0019999 - 14/11/2011 - JMF: Afegir pctipban
   FUNCTION f_nom_domici(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pcdoment IN NUMBER,
      pcdomsuc IN NUMBER,
      pctipban IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_cempres      NUMBER;
      ss             VARCHAR2(3000);
      v_nompack      VARCHAR2(100);
      retorno        VARCHAR2(200);
      ex_nodeclared  EXCEPTION;
      PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);   -- Se debe declarar el componente
      vpasexec       NUMBER := 0;
      vtobjeto       VARCHAR2(500) := 'PAC_NOMBRES_FICHEROS.F_NOM_DOMICI';
      w_pref         VARCHAR2(40);
      w_ext          VARCHAR2(40);
      v_auxparam     VARCHAR2(1000);   -- BUG 0019999 - 14/11/2011 - JMF
   BEGIN
      v_cempres := pac_contexto.f_contextovalorparametro(f_parinstalacion_t('CONTEXT_USER'),
                                                         'IAX_EMPRESA');

      SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_NOMBRES_FICHEROS')
        INTO v_nompack
        FROM DUAL;

      -- ini BUG 0019999 - 14/11/2011 - JMF
      v_auxparam := NULL;
      p_param_pacnombresficheros(v_nompack, v_auxparam, pctipban);
      -- fin BUG 0019999 - 14/11/2011 - JMF
      ss := 'BEGIN ' || ' :RETORNO := ' || v_nompack || '.' || 'f_nom_domici(' || psproces
            || ',' || pcempres || ',' || pcdoment || ',' || pcdomsuc || v_auxparam || ')'
            || ';' || 'END;';
      vpasexec := 1;

      EXECUTE IMMEDIATE ss
                  USING OUT retorno;

      RETURN retorno;
   EXCEPTION
      WHEN ex_nodeclared THEN
--           Esta excepción (ORA-6550 saltará siempre que se realiza una llamada
--           a una función, procedimiento, etc. inexistente o no declarado. En este
--           caso a continación ejecutamos el código tradicional para determinar
--           si la póliza está o no reducida.
         w_pref := NULL;
         w_ext := NULL;
         w_pref := pac_parametros.f_parempresa_t(v_cempres, 'PREFIJO_FICHERO_DOMI');
         w_ext := pac_parametros.f_parempresa_t(v_cempres, 'EXT_FICHERO_DOMI');
         vpasexec := 2;
/*
         IF w_pref IS NULL
            OR w_ext IS NULL THEN
            p_tab_error(f_sysdate, f_user, vtobjeto, vpasexec, f_axis_literales(9901100),
                        f_axis_literales(9901100));
            RETURN('-1');
         END IF;
*/

         -- Bug 28661 - IAX998-Implementar SEPA en iAxis - 17-VII-2014 - dlF
         IF w_ext = '***' AND NVL( pac_parametros.f_parempresa_n(v_cempres, 'DOMIS_IBAN_XML'), 0 ) = 1 THEN

            RETURN w_pref || '_' || TO_CHAR(f_sysdate, 'yyyymmdd_hh24miss') || '_' || psproces || '_' || LPAD(pcdoment, 4, '0') || '_' || LPAD(pcdomsuc, 4, '0') ;

         -- end 31930 - IAX998-Implementar SEPA en iAxis - 17-VII-2014 - dlF
         ELSE

            RETURN w_pref || '_' || TO_CHAR(f_sysdate, 'yyyymmdd_hh24miss') || '_' || psproces || '_' || LPAD(pcdoment, 4, '0') || '_' || LPAD(pcdomsuc, 4, '0') || '.' || w_ext;

         END IF ;

      -- Prefijo.fecha_hora.sproces.Extensión
      WHEN OTHERS THEN
         vpasexec := 3;
         p_tab_error(f_sysdate, f_user, vtobjeto, vpasexec,
                     f_axis_literales(9901092) || '- Sproces: ' || psproces,
                     SQLCODE || '-' || SQLERRM);
         RETURN('-1');
   END f_nom_domici;


   FUNCTION f_nom_transf(pnremesa IN NUMBER, pccc IN VARCHAR2)
      RETURN VARCHAR2 IS
      v_cempres      NUMBER;
      ss             VARCHAR2(3000);
      v_nompack      VARCHAR2(100);
      retorno        VARCHAR2(200);
      ex_nodeclared  EXCEPTION;
      PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);   -- Se debe declarar el componente
      vpasexec       NUMBER := 0;
      vtobjeto       VARCHAR2(500) := 'PAC_NOMBRES_FICHEROS.F_NOM_TRANSF';
      w_pref         VARCHAR2(40);
      w_ext          VARCHAR2(40);
      v_auxparam     VARCHAR2(1000);   -- BUG 0019999 - 14/11/2011 - JMF
   BEGIN
      v_cempres := pac_contexto.f_contextovalorparametro(f_parinstalacion_t('CONTEXT_USER'),
                                                         'IAX_EMPRESA');

      SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_NOMBRES_FICHEROS')
        INTO v_nompack
        FROM DUAL;

      -- ini BUG 0019999 - 14/11/2011 - JMF
      v_auxparam := NULL;
      p_param_pacnombresficheros(v_nompack, v_auxparam, NULL);
      -- fin BUG 0019999 - 14/11/2011 - JMF
      ss := 'BEGIN ' || ' :RETORNO := ' || v_nompack || '.' || 'f_nom_transf(' || CHR(39)
            || pccc || CHR(39) || v_auxparam || ')' || ';' || 'END;';
      vpasexec := 1;

      EXECUTE IMMEDIATE ss
                  USING OUT retorno;

      RETURN retorno;
   EXCEPTION
      WHEN ex_nodeclared THEN
--           Esta excepción (ORA-6550 saltará siempre que se realiza una llamada
--           a una función, procedimiento, etc. inexistente o no declarado. En este
--           caso a continación ejecutamos el código tradicional para determinar
--           si la póliza está o no reducida.
         w_pref := NULL;
         w_ext := NULL;
         w_pref := pac_parametros.f_parempresa_t(v_cempres, 'PREFIJO_FICHERO_TRAN');
         w_ext := pac_parametros.f_parempresa_t(v_cempres, 'EXT_FICHERO_TRAN');
         vpasexec := 2;
/*
         IF w_pref IS NULL
            OR w_ext IS NULL THEN
            p_tab_error(f_sysdate, f_user, vtobjeto, vpasexec, f_axis_literales(9901100),
                        f_axis_literales(9901100));
            RETURN('-1');
         END IF;
*/

         -- Bug 28661 - IAX998-Implementar SEPA en iAxis - 17-VII-2014 - dlF
         IF w_ext = '***' AND NVL( pac_parametros.f_parempresa_n(v_cempres, 'TRANSF_IBAN_XML'), 0 ) = 1 THEN

            RETURN w_pref || '_' || TO_CHAR(f_sysdate, 'yyyymmdd_hh24miss') || '_' || pnremesa || '_' || pccc ;

         -- end 31930 - IAX998-Implementar SEPA en iAxis - 17-VII-2014 - dlF
         ELSE

            RETURN w_pref || '_' || TO_CHAR(f_sysdate, 'yyyymmdd_hh24miss') || '_' || pnremesa || '_' || pccc || '.' || w_ext;

         END IF ;


      WHEN OTHERS THEN
         vpasexec := 3;
         p_tab_error(f_sysdate, f_user, vtobjeto, vpasexec, f_axis_literales(9901092),
                     SQLCODE || '-' || SQLERRM);
         RETURN('-1');
   END f_nom_transf;

   FUNCTION f_nom_tras_ent(psproces IN NUMBER, pordrefitxer IN NUMBER)
      RETURN VARCHAR2 IS
      v_cempres      NUMBER;
      ss             VARCHAR2(3000);
      v_nompack      VARCHAR2(100);
      retorno        VARCHAR2(200);
      ex_nodeclared  EXCEPTION;
      PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);   -- Se debe declarar el componente
      vpasexec       NUMBER := 0;
      vtobjeto       VARCHAR2(500) := 'PAC_NOMBRES_FICHEROS.F_NOM_TRAS_ENT';
      w_pref         VARCHAR2(40);
      w_ext          VARCHAR2(40);
      v_auxparam     VARCHAR2(1000);   -- BUG 0019999 - 14/11/2011 - JMF
   BEGIN
      v_cempres := pac_contexto.f_contextovalorparametro(f_parinstalacion_t('CONTEXT_USER'),
                                                         'IAX_EMPRESA');

      SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_NOMBRES_FICHEROS')
        INTO v_nompack
        FROM DUAL;

      -- ini BUG 0019999 - 14/11/2011 - JMF
      v_auxparam := NULL;
      p_param_pacnombresficheros(v_nompack, v_auxparam, NULL);
      -- fin BUG 0019999 - 14/11/2011 - JMF
      ss := 'BEGIN ' || ' :RETORNO := ' || v_nompack || '.' || 'f_nom_tras_ent(' || v_auxparam
            || ');' || 'END;';
      vpasexec := 1;

      EXECUTE IMMEDIATE ss
                  USING OUT retorno;

      RETURN retorno;
   EXCEPTION
      WHEN ex_nodeclared THEN
--           Esta excepción (ORA-6550 saltará siempre que se realiza una llamada
--           a una función, procedimiento, etc. inexistente o no declarado. En este
--           caso a continación ejecutamos el código tradicional para determinar
--           si la póliza está o no reducida.
         w_pref := NULL;
         w_ext := NULL;
         w_pref := pac_parametros.f_parempresa_t(v_cempres, 'PREFIJO_FICHERO_TRAE');
         w_ext := pac_parametros.f_parempresa_t(v_cempres, 'EXT_FICHERO_TRAE');
         vpasexec := 2;
/*
         IF w_pref IS NULL
            OR w_ext IS NULL THEN
            p_tab_error(f_sysdate, f_user, vtobjeto, vpasexec, f_axis_literales(9901100),
                        f_axis_literales(9901100));
            RETURN('-1');
         END IF;
*/
         RETURN w_pref || '_' || TO_CHAR(f_sysdate, 'yyyymmdd_hh24miss') || '_' || psproces
                || '_' || TO_CHAR(pordrefitxer) || '.' || w_ext;
      WHEN OTHERS THEN
         vpasexec := 3;
         p_tab_error(f_sysdate, f_user, vtobjeto, vpasexec,
                     f_axis_literales(9901092) || ' Sproces: ' || psproces,
                     SQLCODE || '-' || SQLERRM);
         RETURN('-1');
   END f_nom_tras_ent;

   FUNCTION f_nom_tras_sal(psproces IN NUMBER, pordrefitxer IN NUMBER)
      RETURN VARCHAR2 IS
      v_cempres      NUMBER;
      ss             VARCHAR2(3000);
      v_nompack      VARCHAR2(100);
      retorno        VARCHAR2(200);
      ex_nodeclared  EXCEPTION;
      PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);   -- Se debe declarar el componente
      vpasexec       NUMBER := 0;
      vtobjeto       VARCHAR2(500) := 'PAC_NOMBRES_FICHEROS.F_NOM_TRAS_SAL';
      w_pref         VARCHAR2(40);
      w_ext          VARCHAR2(40);
      v_auxparam     VARCHAR2(1000);   -- BUG 0019999 - 14/11/2011 - JMF
   BEGIN
      v_cempres := pac_contexto.f_contextovalorparametro(f_parinstalacion_t('CONTEXT_USER'),
                                                         'IAX_EMPRESA');

      SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_NOMBRES_FICHEROS')
        INTO v_nompack
        FROM DUAL;

      -- ini BUG 0019999 - 14/11/2011 - JMF
      v_auxparam := NULL;
      p_param_pacnombresficheros(v_nompack, v_auxparam, NULL);
      -- fin BUG 0019999 - 14/11/2011 - JMF
      ss := 'BEGIN ' || ' :RETORNO := ' || v_nompack || '.' || 'f_nom_tras_sal(' || v_auxparam
            || ';' || 'END;';
      vpasexec := 1;

      EXECUTE IMMEDIATE ss
                  USING OUT retorno;

      RETURN retorno;
   EXCEPTION
      WHEN ex_nodeclared THEN
--           Esta excepción (ORA-6550 saltará siempre que se realiza una llamada
--           a una función, procedimiento, etc. inexistente o no declarado. En este
--           caso a continación ejecutamos el código tradicional para determinar
--           si la póliza está o no reducida.
         w_pref := NULL;
         w_ext := NULL;
         w_pref := pac_parametros.f_parempresa_t(v_cempres, 'PREFIJO_FICHERO_TRAS');
         w_ext := pac_parametros.f_parempresa_t(v_cempres, 'EXT_FICHERO_TRAS');
         vpasexec := 2;
/*
         IF w_pref IS NULL
            OR w_ext IS NULL THEN
            p_tab_error(f_sysdate, f_user, vtobjeto, vpasexec, f_axis_literales(9901100),
                        f_axis_literales(9901100));
            RETURN('-1');
         END IF;
*/
         RETURN w_pref || '_' || TO_CHAR(f_sysdate, 'yyyymmdd_hh24miss') || '_' || psproces
                || '_' || TO_CHAR(pordrefitxer) || '.' || w_ext;
      WHEN OTHERS THEN
         vpasexec := 3;
         p_tab_error(f_sysdate, f_user, vtobjeto, vpasexec,
                     f_axis_literales(9901092) || '- Sproces: ' || psproces,
                     SQLCODE || '-' || SQLERRM);
         RETURN('-1');
   END f_nom_tras_sal;

   FUNCTION ff_ruta_fichero(pcempres IN NUMBER, pcfichero IN NUMBER, pctipo IN NUMBER)
      RETURN VARCHAR2 IS
      v_ruta         rutas_ficheros.tpath%TYPE;
   BEGIN
      SELECT DECODE(pctipo, 1, tpath, tpath_c)
        INTO v_ruta
        FROM rutas_ficheros
       WHERE cempres = pcempres
         AND cfichero = pcfichero;

      RETURN v_ruta;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'ff_ruta_fichero', 0,
                     'pcempres:' || pcempres || ' pcfichero:' || pcfichero || ' pctipo:'
                     || pctipo,
                     SQLERRM);
         RETURN NULL;
   END ff_ruta_fichero;

   FUNCTION f_ruta_fichero(
      pcempres IN NUMBER,
      pcfichero IN NUMBER,
      ptpath OUT VARCHAR2,
      ptpath_c OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      SELECT tpath, tpath_c
        INTO ptpath, ptpath_c
        FROM rutas_ficheros
       WHERE cempres = pcempres
         AND cfichero = pcfichero;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         ptpath := NULL;
         ptpath_c := NULL;
         p_tab_error(f_sysdate, f_user, 'f_ruta_fichero', 0,
                     'pcempres:' || pcempres || ' pcfichero:' || pcfichero, SQLERRM);
         RETURN SQLCODE;
   END f_ruta_fichero;
END pac_nombres_ficheros;

/

  GRANT EXECUTE ON "AXIS"."PAC_NOMBRES_FICHEROS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_NOMBRES_FICHEROS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_NOMBRES_FICHEROS" TO "PROGRAMADORESCSI";
