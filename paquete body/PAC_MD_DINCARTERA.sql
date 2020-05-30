--------------------------------------------------------
--  DDL for Package Body PAC_MD_DINCARTERA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_DINCARTERA" AS
   /******************************************************************************
      NOMBRE:      PAC_MD_DINCARTERA
      PROPÓSITO:

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        03/12/2008                   1. Creación del package.
      1.1        16/12/2008
      1.2        18/12/2008     xpl           2. Estandarització
      2.0        21/05/2009     RSC           3. Bug 9905: Suplemento de cambio de forma de pago diferido
      3.0        04/01/2011     JMP           4. Bug 0017154: CRE - No permitir lanzar cartera a años futuros o fechas futuras
      4.0        30/07/2012     GAG           5. Bug 0023153: LCOL_T001-Corregir mensajes pac_md_dincartera
      5.0        08/11/2012     APD           6. 0023940: LCOL_T010-LCOL - Certificado 0 renovable - Renovaci?n colectivos
      6.0        09/02/2013     JDS           7. 0025583: LCOL - Revision incidencias qtracker (IV)
      7.0       01/03/2013      FAC           7. 0026209: LCOL_T010-LCOL - Soluci?n definitiva ejecuci?n de cartera desde pantalla
      8.0        04/07/2013     ECP           8. 0027539: LCOL_T010-LCOL - Revision incidencias qtracker (VII). Nota 148366
      9.0        24/01/2014     JSV           9. 0029582: LCOL_T010-Revision incidencias qtracker (2014/01)
      10.0       05/02/2014     JSV           10 0029991: LCOL_T010-Revision incidencias qtracker (2014/02)
      11.0       01/07/2015    IGIL           11 0035888/203837 quitar UPPER a NNUMNIF
      12.0       24/07/2015    BLA           12  35695/210153 Se modifica función f_programar_cartera
   ******************************************************************************/
   /*******************************************************************************
   FUNCION  F_GET_PRODCARTERA
   Función que retornará los productos que cumplen las condiciones de búsqueda según los parámetros informados.
   Esta función llamará a la función pac_dincatera.f_get_prodcartera.
   Parámetros:
    Entrada :
    Pcempres NUMBER  : Id. empresa
    Pcramo   NUMBER  : Id. ramo
    Psproduc NUMBER  : Id. producto
    Salida :
    Mensajes T_IAX_MENSAJES

   Retorna : REF CURSOR.
   ********************************************************************************/
   FUNCTION f_get_prodcartera(
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      psprocar IN NUMBER,
      --Ini Bug 27539 --ECP--04/07/2013
      pmodo IN VARCHAR,
      --Fin Bug 27539 --ECP--04/07/2013
      pcurprcar OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'Pcempres=' || pcempres || ' Pcramo=' || pcramo;
      vobject        VARCHAR2(200) := 'PAC_MD_DINCARTERA.F_GET_PRODCARTERA';
      squery         VARCHAR2(5000);
      vnumerr        NUMBER := 0;
   BEGIN
      -- Control parametros entrada
      IF   --pcramo IS NULL
           --OR
         pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Esta  función deberá seleccionar aquellos productos que pasan cartera, para ello llamará a la función pac_dincatera.f_get_prodcartera..
      vnumerr := pac_dincartera.f_get_prodcartera(pcempres, pcramo, psproduc, psprocar,
                                                  --Ini Bug 27539 --ECP--04/07/2013
                                                  pmodo,
                                                  --Fin Bug 27539 --ECP--04/07/2013
                                                  pac_md_common.f_get_cxtidioma, squery);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);   -- error interno.
         RAISE e_object_error;
      END IF;

      pcurprcar := pac_md_listvalores.f_opencursor(squery, mensajes);
      RETURN vnumerr;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF pcurprcar%ISOPEN THEN
            CLOSE pcurprcar;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF pcurprcar%ISOPEN THEN
            CLOSE pcurprcar;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF pcurprcar%ISOPEN THEN
            CLOSE pcurprcar;
         END IF;

         RETURN 1;
   END f_get_prodcartera;

   /*******************************************************************************
   FUNCION F_SET_PRODCARTERA
   Función que inserta los productos seleccionados para pasar la cartera en el proceso.
    Parámetros:
     Pcempres  NUMBER : Id. empresa
     Psprocar  NUMBER : ID.
     Psproduc  NUMBER : Id. producto
     Pseleccio NUMBER : Valor seleccionado
    Salida :
     Mensajes  T_IAX_MENSAJES

    Retorna: un NUMBER con el id de error.
   ********************************************************************************/
   FUNCTION f_set_prodcartera(
      pcempres IN NUMBER,
      psprocar IN NUMBER,
      psproduc IN NUMBER,
      pseleccio IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'Pcempres=' || pcempres || ' Psprocar=' || psprocar || 'Psproduc=' || psproduc
            || ' Pseleccio=' || pseleccio;
      vobject        VARCHAR2(200) := 'PAC_MD_DINCARTERA.F_SET_PRODCARTERA';
      vnumerr        NUMBER;
   BEGIN
      IF pcempres IS NULL
         OR psprocar IS NULL
         OR psproduc IS NULL
         OR pseleccio IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Esta función llamará a la función pac_dincartera.f_insert_tmp_carteraux.
      vnumerr := pac_dincartera.f_insert_tmp_carteraux(pcempres, psprocar, psproduc, pseleccio);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);   -- error interno.
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_prodcartera;

   /*******************************************************************************
   FUNCION  F_GET_MES_CARTERA
    Parámetros:
      Entrada :
       Pnpoliza   NUMBER : Id. poliza
      Salida :
       Mensajes   T_IAX_MENSAJES
    Retorna : Retorna un ref_cursor.
   ********************************************************************************/
   FUNCTION f_get_mes_cartera(
      pnpoliza IN NUMBER,
      pcempres IN NUMBER,
      pcmodo IN VARCHAR2,
      pcurmescar OUT sys_refcursor,
      mensajes OUT t_iax_mensajes,
      psprocar IN NUMBER   -- Bug 29952/169064 - 11/03/2014 - AMC
                        )
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'Pnpoliza=' || pnpoliza;
      vobject        VARCHAR2(200) := 'PAC_MD_DINCARTERA.F_GET_MES_CARTERA';
      --squery         VARCHAR2(2000);
      v_idioma       NUMBER;
      v_numerr       NUMBER := 0;
      consulta       VARCHAR2(1000);
      v_cagente      agentes.cagente%TYPE;
      v_cempres      procesoscab.cempres%TYPE;   --       v_cempres      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_sproduc      NUMBER;
      v_fcarpro      DATE;
      v_crespue4084  NUMBER;
      v_sseguro      NUMBER;
      v_fcarpro_2num NUMBER;
      vfcarpro_aux   DATE;
      vcount         NUMBER;
      vfecha         DATE;
   BEGIN
      v_idioma := pac_md_common.f_get_cxtidioma;
      v_cagente := ff_agente_usuario(f_user);

      IF pnpoliza IS NOT NULL THEN
         --INI BUG 28821#c157894 --
         SELECT sproduc
           INTO v_sproduc
           FROM seguros
          WHERE npoliza = pnpoliza
            AND ncertif = 0;

         IF NVL(pac_md_param.f_get_parproducto_n(v_sproduc, 'CARTERA_FCARPRO', mensajes), 0) =
                                                                                              1 THEN
            --- Obtener el fcarpro de la póliza
            SELECT fcarpro, sseguro
              INTO v_fcarpro, v_sseguro
              FROM seguros
             WHERE npoliza = pnpoliza
               AND ncertif = 0;

            --Obtener la modalidad de cobro de la póliza
            BEGIN
               SELECT crespue
                 INTO v_crespue4084
                 FROM pregunpolseg
                WHERE cpregun = 4084
                  AND sseguro = v_sseguro
                  AND nmovimi = (SELECT MAX(nmovimi)
                                   FROM pregunpolseg
                                  WHERE sseguro = v_sseguro
                                    AND cpregun = 4084);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_crespue4084 := 2;   -- por defecto
            END;

            --- Si es cobro anticipado solo quier que me muestre el mes de la fcarpro.
            IF v_crespue4084 = 2 THEN   -- Anticipado
               OPEN pcurmescar FOR
                  SELECT   catribu nmes, tatribu tmes
                      FROM detvalores
                     WHERE cvalor = 54
                       AND cidioma = v_idioma
                       AND catribu = TO_NUMBER(TO_CHAR(v_fcarpro, 'MM'))
                  ORDER BY catribu;
            ELSIF v_crespue4084 = 1 THEN   -- Vencido
               -- Bug 30393-180392 - 22/07/2014 - AMC
               SELECT DECODE(TO_NUMBER(TO_CHAR(v_fcarpro, 'MM')) + 1, 12, 13, 12)
                 INTO v_fcarpro_2num
                 FROM DUAL;

               -- Fi Bug 30393-180392 - 22/07/2014 - AMC
               OPEN pcurmescar FOR
                  SELECT   catribu nmes, tatribu tmes
                      FROM detvalores
                     WHERE cvalor = 54
                       AND cidioma = v_idioma
                       AND catribu =(MOD(TO_NUMBER(TO_CHAR(v_fcarpro, 'MM')) + 1,
                                         v_fcarpro_2num))
                  ORDER BY catribu;
            END IF;
         ELSE
            OPEN pcurmescar FOR
               SELECT   catribu nmes, tatribu tmes
                   FROM detvalores
                  WHERE cvalor = 54
                    AND cidioma = v_idioma
               ORDER BY catribu;
         END IF;
      ELSIF pcmodo = 'PREVI_CARTERA'
            AND NVL(pac_parametros.f_parempresa_n(pcempres, 'PREVIO_MESESCARTERA'), 0) = 1 THEN
         OPEN pcurmescar FOR
            SELECT   catribu nmes, tatribu tmes
                FROM detvalores
               WHERE cvalor = 54
                 AND cidioma = v_idioma
            ORDER BY catribu;
      --FIN BUG 28821#c157894 --
      ELSE
         -- Bug 29952/169064 - 11/03/2014 - AMC
         IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                              'MESES_PRODCARTERA'),
                0) = 1 THEN
            -- Bug 30393/168070 - 05/05/2014 - AMC
            SELECT COUNT(fcarpro)
              INTO vcount
              FROM prodagecartera
             WHERE cempres = pcempres
               AND cagente = ff_agente_usuario(f_user)
               AND sproduc IN(SELECT sproduc
                                FROM tmp_carteraux
                               WHERE sprocar = psprocar
                                 AND cestado = 1);

            IF vcount = 0 THEN
               OPEN pcurmescar FOR
                  SELECT   nmes, tmes
                      FROM (SELECT TO_NUMBER(TO_CHAR(fecha, 'mm')) nmes,
                                   ff_desvalorfijo(54, v_idioma,
                                                   TO_NUMBER(TO_CHAR(fecha, 'mm'))) tmes,
                                   TO_NUMBER(TO_CHAR(fecha, 'yyyy')) anyo
                              FROM (SELECT MAX(fcarpro) fecha
                                      FROM prodcartera
                                     WHERE cempres = pcempres
                                       AND sproduc IN(SELECT sproduc
                                                        FROM tmp_carteraux
                                                       WHERE sprocar = psprocar
                                                         AND cestado = 1))
                            UNION
                            SELECT DECODE(TO_CHAR(fecha, 'mm') + 1,
                                          13, 1,
                                          TO_CHAR(fecha, 'mm') + 1) nmes,
                                   ff_desvalorfijo(54, v_idioma,
                                                   DECODE(TO_CHAR(fecha, 'mm') + 1,
                                                          13, 1,
                                                          TO_CHAR(fecha, 'mm') + 1)) tmes,
                                   DECODE(TO_CHAR(fecha, 'mm') + 1,
                                          13, TO_CHAR(fecha, 'yyyy') + 1,
                                          TO_CHAR(fecha, 'yyyy')) anyo
                              FROM (SELECT MAX(fcarpro) fecha
                                      FROM prodcartera
                                     WHERE cempres = pcempres
                                       AND sproduc IN(SELECT sproduc
                                                        FROM tmp_carteraux
                                                       WHERE sprocar = psprocar
                                                         AND cestado = 1))
                            UNION
                            SELECT DECODE(TO_CHAR(fecha, 'mm') - 1,
                                          0, 12,
                                          TO_CHAR(fecha, 'mm') - 1) nmes,
                                   ff_desvalorfijo(54, v_idioma,
                                                   DECODE(TO_CHAR(fecha, 'mm') - 1,
                                                          0, 12,
                                                          TO_CHAR(fecha, 'mm') - 1)) tmes,
                                   DECODE(TO_CHAR(fecha, 'yyyy') - 1,
                                          0, 12,
                                          TO_CHAR(fecha, 'yyyy') - 1) anyo
                              FROM (SELECT MAX(fcarpro) fecha
                                      FROM prodcartera
                                     WHERE cempres = pcempres
                                       AND sproduc IN(SELECT sproduc
                                                        FROM tmp_carteraux
                                                       WHERE sprocar = psprocar
                                                         AND cestado = 1)))
                     WHERE anyo || nmes IS NOT NULL
                  ORDER BY anyo || nmes;
            ELSE
               SELECT MAX(fecha)
                 INTO vfecha
                 FROM (SELECT MAX(fcarpro) fecha
                         FROM prodagecartera
                        WHERE cempres = pcempres
                          AND cagente = ff_agente_usuario(f_user)
                          AND sproduc IN(SELECT sproduc
                                           FROM tmp_carteraux
                                          WHERE sprocar = psprocar
                                            AND cestado = 1)
                       UNION
                       SELECT MAX(fcarpro) fecha
                         FROM prodagecartera
                        WHERE cempres = pcempres
                          AND cagente = (SELECT cagente
                                           FROM redcomercial
                                          WHERE cempres = pcempres
                                            AND ctipage = 0)
                          AND sproduc IN(SELECT sproduc
                                           FROM tmp_carteraux
                                          WHERE sprocar = psprocar
                                            AND cestado = 1)
                       UNION
                       SELECT MAX(fcarpro) fecha
                         FROM prodcartera
                        WHERE cempres = pcempres
                          AND sproduc IN(SELECT sproduc
                                           FROM tmp_carteraux
                                          WHERE sprocar = psprocar
                                            AND cestado = 1));

               OPEN pcurmescar FOR
                  SELECT   nmes, tmes
                      FROM (SELECT TO_NUMBER(TO_CHAR(vfecha, 'mm')) nmes,
                                   ff_desvalorfijo(54, v_idioma,
                                                   TO_NUMBER(TO_CHAR(vfecha, 'mm'))) tmes,
                                   TO_NUMBER(TO_CHAR(vfecha, 'yyyy')) anyo
                              FROM DUAL
                            UNION
                            SELECT DECODE(TO_CHAR(vfecha, 'mm') + 1,
                                          13, 1,
                                          TO_CHAR(vfecha, 'mm') + 1) nmes,
                                   ff_desvalorfijo(54, v_idioma,
                                                   DECODE(TO_CHAR(vfecha, 'mm') + 1,
                                                          13, 1,
                                                          TO_CHAR(vfecha, 'mm') + 1)) tmes,
                                   DECODE(TO_CHAR(vfecha, 'mm') + 1,
                                          13, TO_CHAR(vfecha, 'yyyy') + 1,
                                          TO_CHAR(vfecha, 'yyyy')) anyo
                              FROM DUAL
                            UNION
                            SELECT DECODE(TO_CHAR(vfecha, 'mm') - 1,
                                          0, 12,
                                          TO_CHAR(vfecha, 'mm') - 1) nmes,
                                   ff_desvalorfijo(54, v_idioma,
                                                   DECODE(TO_CHAR(vfecha, 'mm') - 1,
                                                          0, 12,
                                                          TO_CHAR(vfecha, 'mm') - 1)) tmes,
                                   DECODE(TO_CHAR(vfecha, 'yyyy') - 1,
                                          0, 12,
                                          TO_CHAR(vfecha, 'yyyy') - 1) anyo
                              FROM DUAL)
                     WHERE anyo || nmes IS NOT NULL
                  ORDER BY anyo || nmes;
            END IF;
         -- Fi Bug 30393/168070 - 05/05/2014 - AMC
         ELSE
            OPEN pcurmescar FOR
               SELECT TO_NUMBER(TO_CHAR(fcarpro, 'mm')) nmes,
                      ff_desvalorfijo(54, v_idioma, TO_CHAR(fcarpro, 'mm')) tmes
                 FROM empresas
                WHERE cempres = pcempres
               UNION
               SELECT DECODE(TO_CHAR(fcarpro, 'mm') + 1,
                             13, 1,
                             TO_CHAR(fcarpro, 'mm') + 1) nmes,
                      ff_desvalorfijo(54, v_idioma,
                                      DECODE(TO_CHAR(fcarpro, 'mm') + 1,
                                             13, 1,
                                             TO_CHAR(fcarpro, 'mm') + 1)) tmes
                 FROM empresas
                WHERE cempres = pcempres
               UNION
               SELECT DECODE(TO_CHAR(fcarpro, 'mm') - 1,
                             0, 12,
                             TO_CHAR(fcarpro, 'mm') - 1) nmes,
                      ff_desvalorfijo(54, v_idioma,
                                      DECODE(TO_CHAR(fcarpro, 'mm') - 1,
                                             0, 12,
                                             TO_CHAR(fcarpro, 'mm') - 1)) tmes
                 FROM empresas
                WHERE cempres = pcempres;
         END IF;
      -- Fi Bug 29952/169064 - 11/03/2014 - AMC
      END IF;

      vpasexec := 2;
      RETURN 0;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF pcurmescar%ISOPEN THEN
            CLOSE pcurmescar;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF pcurmescar%ISOPEN THEN
            CLOSE pcurmescar;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF pcurmescar%ISOPEN THEN
            CLOSE pcurmescar;
         END IF;

         RETURN 1;
   END f_get_mes_cartera;

   /*******************************************************************************
   FUNCION F_REGISTRA_PROCESO
   Esta función deberá realizar una llamada a la función de la capa de negocio pac_dincartera.f_inicializa_cartera.
    Parámetros
     Entrada :
       Pmodo    NUMBER : Modo ejecucion
       Pfperini NUMBER : Fecha inicio
       Pcempres NUMBER : Empresa

     Salida :
       Mensajes   T_IAX_MENSAJES

    Retorna : NUMBER con el número de proceso.
   ********************************************************************************/
   FUNCTION f_registra_proceso(
      pmodo IN VARCHAR2,
      pmes IN NUMBER,
      panyo IN NUMBER,
      pcempres IN NUMBER,
      pfcartera IN DATE,
      pnproceso OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pmodo=' || pmodo || ' pmes=' || pmes || ' panyo = ' || panyo || 'pcempres='
            || pcempres || ' pfcartera = ' || pfcartera;
      vobject        VARCHAR2(200) := 'PAC_MD_DINCARTERA.F_REGISTRA_PROCESO';
      vnumerr        NUMBER;
      vtexto         VARCHAR2(100);
      pfperini       DATE;
   BEGIN
      -- Control parametros entrada
      --Si la fecha de cartera es null, tiene que haber algo tanto en ANYO como en MES
      IF pfcartera IS NULL
         AND(panyo IS NULL
             OR pmes IS NULL) THEN
         RAISE e_param_error;
      END IF;

      IF pmodo IS NULL
         OR pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pfcartera IS NULL THEN
         pfperini := TO_DATE('01/' || TO_CHAR(pmes) || '/' || TO_CHAR(panyo), 'dd/mm/yyyy');
      ELSE
         pfperini := pfcartera;
      END IF;

      vnumerr := pac_dincartera.f_inicializa_cartera(pmodo, pfperini, pcempres,
                                                     'REGISTRO DE CARTERA',
                                                     pac_md_common.f_get_cxtidioma, pnproceso);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);   -- error interno.
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_registra_proceso;

   /*******************************************************************************
   FUNCTION F_GET_ANYO_CARTERA
    Esta función deberá realizar una llamada a la función de la capa de negocio pac_dincartera.f_get_anyo_cartera
    Parámetros
     Entrada :
      Pnpoliza   NUMBER : Numero de Poliza
      Pnmes      NUMBER : Mes
     Salida:
      Mensajes   T_IAX_MENSAJES
    Retorna : NUMBER
   ********************************************************************************/
   FUNCTION f_get_anyo_cartera(
      pcempres IN NUMBER,
      pnpoliza IN NUMBER,
      pnmes IN NUMBER,
      pnanyo OUT NUMBER,
      mensajes OUT t_iax_mensajes,
      psprocar IN NUMBER   -- Bug 29952/169064 - 11/03/2014 - AMC
                        )
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(200) := 'Pnpoliza=' || pnpoliza || ' Pnmes=' || pnmes;
      vobject        VARCHAR2(200) := 'PAC_MD_DINCARTERA.F_GET_ANYO CARTERA';
      vnumerr        NUMBER;
      pcidioma       NUMBER;
   BEGIN
      -- Control parametros entrada
      IF pnmes IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Esta función deberá realizar una llamada a la función de la capa de negocio pac_dincartera.f_get_anyo_cartera
      vpasexec := 2;
      vnumerr := pac_dincartera.f_get_anyo_cartera(pcempres, pnpoliza, pnmes, pnanyo, psprocar);   -- Bug 29952/169064 - 11/03/2014 - AMC

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);   -- error interno.
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_anyo_cartera;

   /*******************************************************************************
   FUNCION  F_LANZA_CARTERA
   Esta función deberá realizar una llamada a la función de la capa de negocio pac_dincartera.f_ejecuta_cartera,
   con el parámetro modo a 0.
   Parámetros
    Entrada:
       psproces   NUMBER : Id. proceso
       pcempres   NUMBER : Id. empresa
       pmes       NUMBER : Mes
       panyo      NUMBER : Año
       pnpoliza   NUMBER : Numero de poliza
       pncertif   NUMBER : Numero de certificado
       Psprocar   NUMBER : Id.
    Salida :
       Mensajes   T_IAX_MENSAJES
   Retorna : NUMBER con el id del error.
   ********************************************************************************/
   FUNCTION f_lanza_cartera(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pmes IN NUMBER,
      panyo IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      psprocar IN NUMBER,
      pfcartera IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psproces=' || psproces || ' pcempres =' || pcempres || 'pmes=' || pmes
            || ' panyo =' || panyo || ' pnpoliza =' || pnpoliza || 'pncertif=' || pncertif
            || ' psprocar =' || psprocar || ' pfcartera=' || pfcartera;
      vobject        VARCHAR2(200) := 'PAC_MD_DINCARTERA.F_LANZA_CARTERA';
      num            NUMBER;
      pfperini       DATE;
      pconta_error   NUMBER;
      pcidioma       NUMBER;
      vnumerr        NUMBER := 0;
      vmens          VARCHAR2(250);
      v_meses        parempresas.nvalpar%TYPE;
      v_fecha_comp   DATE;
      v_sproduc      seguros.sproduc%TYPE;
      vcarterabatch  NUMBER := 0;
      v_plsql        VARCHAR2(1000);
      vcount         NUMBER;   --Bug 29765/164894 - 31/01/2014 - AMC
      vfcarpro       DATE;   --Bug 29765/164894 - 31/01/2014 - AMC
      v_jobtype      NUMBER;
      vcproces       job_codiproces.cproces%TYPE;
      vtclave        job_colaproces.tclave%TYPE;
   BEGIN
      -- Control parametros entrada
      --Si la fecha de cartera es null, tiene que haber algo tanto en ANYO como en MES
      IF pfcartera IS NULL
         AND(panyo IS NULL
             OR pmes IS NULL) THEN
         RAISE e_param_error;
      END IF;

      IF psproces IS NULL
         OR psprocar IS NULL
         OR pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pfcartera IS NULL THEN
         pfperini := TO_DATE('01/' || TO_CHAR(pmes) || '/' || TO_CHAR(panyo), 'dd/mm/yyyy');
      ELSE
         pfperini := pfcartera;
      END IF;

      -- BUG 17154 - 04/01/2011 - JMP - No permitir lanzar cartera a años futuros o fechas futuras
      v_meses := pac_parametros.f_parempresa_n(pcempres, 'CARTERA_BLOQUEA');

      IF pnpoliza IS NULL THEN
         v_fecha_comp := TRUNC(f_sysdate);
      ELSE
         -- BUG 23153 - 30/07/2012 - GAG - 0023153: LCOL_T001-Corregir mensajes pac_md_dincartera
         BEGIN
            SELECT MAX(sproduc)
              INTO v_sproduc
              FROM seguros
             WHERE npoliza = pnpoliza;

            IF NVL(f_parproductos_v(v_sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
               AND NVL(pncertif, 0) = 0 THEN
               v_fecha_comp := TRUNC(f_sysdate);
            ELSE
               SELECT fcarpro
                 INTO v_fecha_comp
                 FROM seguros
                WHERE npoliza = pnpoliza
                  AND ncertif = NVL(pncertif, 0);
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9904077);
               vnumerr := 1;
         END;
      END IF;

      IF vnumerr = 0 THEN
         IF MONTHS_BETWEEN(LAST_DAY(pfperini), v_fecha_comp) > v_meses THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9901777);   -- Fecha de cartera superior a la permitida por el sistema
            vnumerr := 1;
         ELSE
            --Bug 29765/164894 - 31/01/2014 - AMC
            IF NVL(pac_parametros.f_parempresa_n(pcempres, 'MISMA_FCARTERA'), 0) = 1 THEN
               IF pnpoliza IS NULL THEN
                  SELECT COUNT(1)
                    INTO vcount
                    FROM tmp_carteraux
                   WHERE sprocar = psprocar
                     AND cestado = 1;

                  IF vcount > 1 THEN
                     SELECT sproduc
                       INTO v_sproduc
                       FROM tmp_carteraux
                      WHERE sprocar = psprocar
                        AND cestado = 1
                        AND ROWNUM = 1;

                     SELECT fcarpro
                       INTO vfcarpro
                       FROM prodcartera
                      WHERE sproduc = v_sproduc
                        AND cempres = pac_md_common.f_get_cxtempresa();

                     FOR c IN (SELECT p.fcarpro
                                 FROM prodcartera p, tmp_carteraux t
                                WHERE t.sprocar = psprocar
                                  AND p.sproduc = t.sproduc
                                  AND t.sproduc <> v_sproduc
                                  AND t.cestado = 1
                                  AND p.cempres = pac_md_common.f_get_cxtempresa) LOOP
                        IF c.fcarpro <> vfcarpro THEN
                           pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9906464);
                           RETURN 1;
                        END IF;
                     END LOOP;
                  END IF;
               END IF;
            END IF;

            --Fi Bug 29765/164894 - 31/01/2014 - AMC

            -- FIN BUG 17154 - 04/01/2011 - JMP
            vcarterabatch := pac_parametros.f_parempresa_n(pcempres, 'CARTERA_BATCH');

            IF vcarterabatch = 1 THEN
               DECLARE
                  FUNCTION f_nulos(p_camp IN VARCHAR2, p_tip IN NUMBER DEFAULT 1)
                     RETURN VARCHAR2 IS
                  BEGIN
                     vpasexec := 44;

                     IF p_camp IS NULL THEN
                        RETURN ' null';
                     ELSE
                        IF p_tip = 2 THEN
                           RETURN ' to_date(' || CHR(39) || p_camp || CHR(39)
                                  || ',''ddmmyyyy'')';
                        ELSE
                           RETURN ' ' || p_camp;
                        END IF;
                     END IF;
                  END;
               BEGIN
                  vpasexec := 45;
                  --JLV 29/05/2013 para no perder el usuario
                  v_plsql := 'declare num_err NUMBER; begin ' || CHR(10)
                             || 'num_err:= pac_contexto.f_inicializarctx(' || CHR(39)
                             || f_user || CHR(39) || ');' || CHR(10) || 'P_EJECUTAR_CARTERA('
                             || f_nulos(psproces) || ',' || CHR(39) || 'CARTERA' || CHR(39)
                             || ',' || f_nulos(pcempres) || ',' || f_nulos(pnpoliza) || ','
                             || f_nulos(TO_CHAR(pfperini, 'ddmmyyyy'), 2) || ',' || ' '
                             || f_nulos(pncertif) || ','
                             || f_nulos(pac_monedas.f_moneda_producto(v_sproduc)) || ','
                             || f_nulos(pac_md_common.f_get_cxtidioma) || ','
                             || f_nulos(psprocar) || ',' || 'NULL' || ',' || 'NULL' || ','
                             || f_nulos(TO_CHAR(pfcartera, 'ddmmyyyy'), 2) || '); ' || CHR(10)
                             || ' end;';
                  v_jobtype := NVL(pac_md_param.f_parinstalacion_nn('JOB_TYPE', mensajes), 0);

                  IF v_jobtype = 0 THEN
                     vnumerr := pac_jobs.f_ejecuta_job(NULL, v_plsql, NULL);
                  ELSIF v_jobtype IN(1, 2) THEN
                     IF v_jobtype = 2 THEN
                        IF pnpoliza IS NOT NULL THEN
                           --Cartera de una poliza
                           vcproces := 4;
                           vnumerr := pac_seguros.f_get_sseguro(pnpoliza, pncertif, 'POL',
                                                                vtclave);
                        ELSE
                           --Cartera por productos
                           vcproces := 6;

                           FOR x IN (SELECT sproduc
                                       FROM tmp_carteraux
                                      WHERE sprocar = psprocar
                                        AND cestado = 1) LOOP
                              vtclave := vtclave || x.sproduc || '|';
                           END LOOP;
                        END IF;
                     END IF;

                     vnumerr := pac_jobs.f_inscolaproces(vcproces, v_plsql, psproces, vtclave);
                  END IF;

                  IF vnumerr <> 0 THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);   -- error interno.
                     RAISE e_object_error;
                  END IF;

                  pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes, 2, NULL,
                                              f_axis_literales(9000493,
                                                               pac_md_common.f_get_cxtidioma)
                                              || ' : ' || psproces || '.'
                                              || f_axis_literales
                                                                 (9905059,
                                                                  pac_md_common.f_get_cxtidioma));

                  IF vnumerr > 0 THEN
                     p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                                 ' men=' || vnumerr);
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 6, vnumerr);
                     RETURN 1;
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                                 vparam || ' men=' || vnumerr, SQLCODE || ' ' || SQLERRM);
                     pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec,
                                                       vparam, psqcode => SQLCODE,
                                                       psqerrm => SQLERRM);
                     RETURN 1;
               END;
            ELSE
               vnumerr :=
                  pac_dincartera.f_ejecutar_cartera(psproces, 'CARTERA', pcempres, pnpoliza,
                                                    pfperini, pfcartera, pncertif,

                                                    -- JLB - I - BUG 18423 COjo la moneda del producto
                                                    --                                         f_parinstalacion_n('MONEDAINST'),
                                                    pac_monedas.f_moneda_producto(v_sproduc),

                                                    -- JLB - F - BUG 18423 COjo la moneda del producto
                                                    pac_md_common.f_get_cxtidioma, psprocar,
                                                    NULL, vmens);

               IF vnumerr <> 0 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);   -- error interno.
                  RAISE e_object_error;
               END IF;

               pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes, 2, NULL,
                                              f_axis_literales(9000493,
                                                               pac_md_common.f_get_cxtidioma)
                                              || ' : ' || psproces);
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, NULL, vmens);
            END IF;
         END IF;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_lanza_cartera;

   /*******************************************************************************
   FUNCION  F_LANZA_PREVICARTERA
   Esta función deberá realizar una llamada a la función de la capa de negocio pac_dincartera.f_ejecuta_cartera,
   con el modo a 1.
   Parámetros
    Entrada :
       psproces   NUMBER : Id. proceso
       pcempres   NUMBER : Id. empresa
       pmes       NUMBER : Mes
       panyo      NUMBER : Año
       pnpoliza   NUMBER : Numero de poliza
       pncertif   NUMBER : Numero de certificado
       psprocar   NUMBER : Id.
       prenuevan  NUMBER

    Salida :
      Mensajes  T_IAX_MENSAJES

   Retorna : NUMBER con el id del error.
   ********************************************************************************/
   FUNCTION f_lanza_previcartera(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pmes IN NUMBER,
      panyo IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      psprocar IN NUMBER,
      prenuevan IN NUMBER,
      pfcartera IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psproces=' || psproces || ' pcempres =' || pcempres || ' pmes=' || pmes
            || ' panyo =' || panyo || ' pnpoliza =' || pnpoliza || ' pncertif=' || pncertif
            || ' psprocar =' || psprocar || ' prenuevan =' || prenuevan || ' pfcartera ='
            || pfcartera;
      vobject        VARCHAR2(200) := 'PAC_MD_DINCARTERA.F_LANZA_PREVICARTERA';
      vnumerr        NUMBER;
      pfperini       DATE;
      vmens          VARCHAR2(250);
      vcarterabatch  NUMBER := 0;
      pmodo          VARCHAR(20);
      v_plsql        VARCHAR2(1000);
   BEGIN
      -- Control parametros entrada
      IF pfcartera IS NULL
         AND(panyo IS NULL
             OR pmes IS NULL) THEN
         RAISE e_param_error;
      END IF;

      IF psproces IS NULL
         OR psprocar IS NULL
         OR pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF panyo IS NOT NULL
         AND pmes IS NOT NULL THEN
         pfperini := TO_DATE('01/' || TO_CHAR(pmes) || '/' || TO_CHAR(panyo), 'dd/mm/yyyy');
      ELSE   -- Bug 32705/189673 - 07/11/2014 - AMC
         pfperini := pfcartera;
      END IF;

      -- Bug 26209 FAC - INI 27/02/2013 - Solución definitiva ejecución de cartera desde pantalla
      vcarterabatch := pac_parametros.f_parempresa_n(pcempres, 'CARTERA_BATCH');

      IF vcarterabatch = 1 THEN
         DECLARE
            FUNCTION f_nulos(p_camp IN VARCHAR2, p_tip IN NUMBER DEFAULT 1)
               RETURN VARCHAR2 IS
            BEGIN
               vpasexec := 44;

               IF p_camp IS NULL THEN
                  RETURN ' null';
               ELSE
                  IF p_tip = 2 THEN
                     RETURN ' to_date(' || CHR(39) || p_camp || CHR(39) || ',''ddmmyyyy'')';
                  ELSE
                     RETURN ' ' || p_camp;
                  END IF;
               END IF;
            END;
         BEGIN
            vpasexec := 45;
            --JLV 29/05/2013 para no perder el usuario
            v_plsql := 'declare num_err NUMBER; begin ' || CHR(10)
                       || 'num_err:= pac_contexto.f_inicializarctx(' || CHR(39) || f_user
                       || CHR(39) || ');' || CHR(10) || 'P_EJECUTAR_CARTERA('
                       || f_nulos(psproces) || ',' || CHR(39) || 'PREVI' || CHR(39) || ','
                       || f_nulos(pcempres) || ',' || f_nulos(pnpoliza) || ','
                       || f_nulos(TO_CHAR(pfperini, 'ddmmyyyy'), 2) || ',' || ' '
                       || f_nulos(pncertif) || ','
                       || f_nulos(f_parinstalacion_n('MONEDAINST')) || ','
                       || f_nulos(pac_md_common.f_get_cxtidioma) || ',' || f_nulos(psprocar)
                       || ',' || f_nulos(prenuevan) || ',' || f_nulos(vmens) || ','
                       || f_nulos(TO_CHAR(pfcartera, 'ddmmyyyy'), 2) || '); ' || CHR(10)
                       || ' end;';
            vnumerr := pac_jobs.f_ejecuta_job(NULL, v_plsql, NULL);

            IF vnumerr <> 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);   -- error interno.
               RAISE e_object_error;
            END IF;

            pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes, 2, NULL,
                                              f_axis_literales(9000493,
                                                               pac_md_common.f_get_cxtidioma)
                                              || ' : ' || psproces || '.'
                                              || f_axis_literales
                                                                 (9905059,
                                                                  pac_md_common.f_get_cxtidioma));

            IF vnumerr > 0 THEN
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, ' men=' || vnumerr);
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 6, vnumerr);
               RETURN 1;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam || ' men=' || vnumerr,
                           SQLCODE || ' ' || SQLERRM);
               pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                                 psqcode => SQLCODE, psqerrm => SQLERRM);
               RETURN 1;
         END;
      ELSE
         vnumerr := pac_dincartera.f_ejecutar_cartera(psproces, 'PREVI', pcempres, pnpoliza,
                                                      pfperini, pfcartera, pncertif,
                                                      f_parinstalacion_n('MONEDAINST'),
                                                      pac_md_common.f_get_cxtidioma, psprocar,
                                                      prenuevan, vmens);

         IF vnumerr <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);   -- error interno.
            RAISE e_object_error;
         END IF;

         pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes, 2, NULL,
                                              f_axis_literales(9000493,
                                                               pac_md_common.f_get_cxtidioma)
                                              || ' : ' || psproces);
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, NULL, vmens);
      END IF;

      -- Bug 26209  FAC - FIN 27/02/2013 - Solución definitiva ejecución de cartera desde pantalla
      RETURN vnumerr;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_lanza_previcartera;

   /*******************************************************************************
   FUNCION  F_LISTADO_CARTERA
    Impresión de reports
   Parametros.
    Entrada :
       Report   varchar2 : Id. del report
       Pcempres number   : Id. empresa
       Pselprod varchar2 : Valor seleccionado
       Psproces number   : Id. proceso
       Pmes     NUMBER   : Mes
       Panyo    NUMBER   : Año
       Psprocar number   : Id.

    Salida :
       Mensajes  T_IAX_MENSAJES
   Retorna : NUMBER con el id del error.
   ********************************************************************************/
   FUNCTION f_listado_cartera(
      report IN VARCHAR2,
      pcempres IN NUMBER,
      pselprod IN VARCHAR2,
      psproces IN NUMBER,
      pmes IN NUMBER,
      panyo IN NUMBER,
      psprocar IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := ' Report=' || report || ' pcempres =' || pcempres || ' Pselprod=' || pselprod
            || ' psproces=' || psproces || ' pmes=' || pmes || ' panyo =' || panyo
            || ' Psprocar =' || psprocar;
      vobject        VARCHAR2(200) := 'PAC_MD_DINCARTERA.F_LISTADO_CARTERA';
      num            NUMBER;
      nom            VARCHAR2(300);
      vstr           VARCHAR2(2000);
      vproductos     VARCHAR2(1000);
      vfemisio       DATE;
      vfinicio       DATE;
      vffin          DATE;
   BEGIN
      mensajes := t_iax_mensajes();

      -- Control parametros entrada
      IF report IS NULL
         OR psproces IS NULL
         OR psprocar IS NULL
         OR pcempres IS NULL
         OR pselprod IS NULL
         OR pmes IS NULL
         OR panyo IS NULL THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     'Faltan parametros por informar: ' || vparam, SQLERRM);
         RETURN 140974;   --Faltan parametros por informar
      END IF;

      /*******************************************************************************
       FALTA La parte de  PAC_MD_MENU.F_Get_UrlReports(report,mensajes);
      ********************************************************************************/
      RETURN 0;
      /*
      Para crear la cadena de texto que sirve para la selección de productos se deberá concatenar una condición
      "and sproduc in " …., con los registros de la tabla tmp_carteraux del sprocar recibido por parámetro ,
      que tengan el estado seleccionado.
      */
      vproductos := ' and sproduc in (';

      FOR cur IN (SELECT sproduc
                    FROM tmp_carteraux
                   WHERE sprocar = psprocar
                     AND cestado = pselprod) LOOP
         vproductos := vproductos || cur.sproduc || ',';
      END LOOP;

      IF vproductos <> ' and sproduc in (' THEN
         -- Quitar la ultima ','
         vproductos := SUBSTR(vproductos, 1, LENGTH(vproductos) - 1) || ')';
      ELSE
         vproductos := NULL;
      END IF;

      /*
      Parametros especiales para el report de cartera.
      La fecha de emisión corresponderá con el dia 1 del mes y año seleccionado, esta fecha será la misma que la fecha de inicio
      de efecto . La fecha de fin de efecto es el último dia de mes , del mes y año seleccionado.
      */
      vfinicio := TO_DATE('01/' || pmes || '/' || panyo, 'dd/mm/yyyy');
      vffin := TO_DATE(LAST_DAY(TO_DATE('01/' || pmes || '/' || panyo, 'dd/mm/yyyy')) || '/'
                       || pmes || '/' || panyo,
                       'dd/mm/yyyy');
      vfemisio := vfinicio;
      /* Para la impresión de reports , se llamará a la función f_get_urlreport, concatenando los parámetros de sistema
        (orientación, salida en fichero,etc con los parámetros de cada uno de los reports), el resultado será una url que se
        llamará desde la pantalla lanzando así los listados.
      */
      vpasexec := 2;

       -- Se busca la parte común de la cadena para lanzar el report
       --*** Pendiente de tener la funcion PAC_MD_MENU.F_Get_UrlReports
      --*** vstr:= PAC_MD_MENU.F_Get_UrlReports(report,mensajes);
      IF vstr IS NULL THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 3;
      -- Se completa la cadena para lanzar el report
      vstr := vstr || 'REPORT=' || report || '&' || 'DESTYPE=CACHE' || '&' || 'DESFORMAT=PDF';

      --*** '&'||'P_USU_IDIOMA='||PAC_MD_COMMON.F_GET_CXTIDIOMA;

      --En caso de que el report se alctr304(previo de cartera), los parámetros a concatenar son el código de proceso y el
      --  código de empresa.
      IF UPPER(report) = 'ALCTR304' THEN
         vstr := vstr || '&' || 'P_CEMPRES=' || pcempres || '&' || 'P_SPROCES=' || psproces;
      ELSIF UPPER(report) = 'SNCTR012' THEN
         --En el caso del report snctr012 ( pólizas que renuevan), los parámetros a concatenar son el código de proceso PSPROCES y
         --el código de empresa PEMPRES.
         vstr := vstr || '&' || 'P_CEMPRES=' || pcempres || '&' || 'P_SPROCES=' || psproces;
      ELSIF UPPER(report) = 'ALCTR303' THEN
         --Report alctr303 (cartera), los parámetros a concatenar son el código de empresa, y la condición and de los productos
         --seleccionados. Fecha de emisión
         vstr := vstr || '&' || 'P_CEMPRES=' || pcempres || '&' || 'P_FEMISIO=' || vfemisio
                 || '&' || 'P_WHERE=' || vproductos;
      ELSIF UPPER(report) = 'SNCTR05' THEN
         -- Snctr05( renovación de cartera), empresa, fecha de inicio, fecha fin, y selección de productos
         vstr := vstr || '&' || 'P_CEMPRES=' || pcempres || '&' || 'P_FINICIO=' || vfinicio
                 || '&' || 'P_FFIN=' || vffin || '&' || 'P_WHERE=' || vproductos;
      END IF;

      /*
          vstr := vstr ||'&'||'REPORT='||report||
                              '&'||'DESTYPE=CACHE'||
                              '&'||'DESFORMAT=PDF'||
                              '&'||'P_USU_IDIOMA='||PAC_MD_COMMON.F_GET_CXTIDIOMA||
                              '&'||'P_CEMPRES='||pempresa||
                              '&'||'P_MONEDA='||PAC_MD_COMMON.F_GET_PARINSTALACION_N('MONEDAINST')||
                              '&'||'P_SPROCES='||psproces;

      */
      vpasexec := 4;

      --Al finalizar el proceso se debe eliminar los registros de la tabla tmp_carteraux para el sprocar recibido.
      DELETE FROM tmp_carteraux
            WHERE sprocar = psprocar;

      COMMIT;
      vpasexec := 5;
      RETURN nom;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_listado_cartera;

   /*******************************************************************************
    FUNCION f_eval_genera_diferidos
    Nos indicará si debe o no generarse el MAP de información de pólizas que sufrirán
    un suplemento automático o un suplemento diferido en la cartera indicada por
    parámetro.

    Parámetros:
       pcempres NUMBER: Código de empresa seleccionada en pantalla de previo de cartera.
       psproces NUMBER: Identificador de proceso.
       pgeneramap NUMBER: 0 (no genera map) o 1 (si genera map)
     Salida :
       Mensajes   T_IAX_MENSAJES
    Retorna: NUMBER.
   ********************************************************************************/
   -- Bug 9905 - 21/05/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_eval_genera_diferidos(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pgeneramap OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := '';
      vobject        VARCHAR2(200) := 'PAC_MD_DINCARTERA.f_eval_genera_diferidos';
      vnumerr        NUMBER := 0;
      v_pfcartera    DATE;
   BEGIN
      BEGIN
         SELECT DISTINCT femisio
                    INTO v_pfcartera
                    FROM reciboscar
                   WHERE sproces = psproces;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            pgeneramap := 0;
            RETURN 0;
      END;

      vnumerr := pac_sup_diferidos.f_eval_genera_map(pcempres, psproces, v_pfcartera,
                                                     pgeneramap);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_eval_genera_diferidos;

-- Fin Bug 9905

   -- Bug 23940 - APD - 08/11/2012 - se crea la funcion
   -- Bug 29991/0165373 - JSV - 04/02/2014 - Se añade JOIN con prodcartera
   FUNCTION f_consulta_gestrenova(
      pramo IN NUMBER,
      psproduc IN NUMBER,
      pnpoliza IN NUMBER,
      pncert IN NUMBER DEFAULT -1,
      pnnumide IN VARCHAR2,
      psnip IN VARCHAR2,
      pbuscar IN VARCHAR2,
      pnsolici IN NUMBER,
      ptipopersona IN NUMBER,
      pcagente IN NUMBER,
      pcmatric IN VARCHAR2,
      pcpostal IN VARCHAR2,
      ptdomici IN VARCHAR2,
      ptnatrie IN VARCHAR2,
      pcsituac IN NUMBER,
      p_filtroprod IN VARCHAR2,
      pcpolcia IN VARCHAR2,
      pccompani IN NUMBER,
      pcactivi IN NUMBER,
      pcestsupl IN NUMBER,
      pnpolini IN VARCHAR2,
      pfilage IN NUMBER DEFAULT 1,
      pfvencimini IN DATE,
      pfvencimfin IN DATE,
      psucurofi IN VARCHAR2,
      pmodo IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      squery         VARCHAR2(4000);
      buscar         VARCHAR2(4000) := ' where 1=1 ';
      subus          VARCHAR2(500);
      tabtp          VARCHAR2(10);
      tabtp_ase      VARCHAR2(20);
      auxnom         VARCHAR2(200);
      v_nom          VARCHAR2(200);
      empresa        NUMBER;
      nerr           NUMBER;
      v_sentence     VARCHAR2(500);
      vpasexec       NUMBER(8) := 1;
      vform          VARCHAR2(4000) := '';
      vparam         VARCHAR2(500)
         := 'psproduc=' || psproduc || ' pnpoliza: ' || pnpoliza || ' pncert=' || pncert
            || ' pnnumide=' || pnnumide || ' psnip=' || psnip || ' pbuscar=' || pbuscar
            || ' ptipopersona=' || ptipopersona || ' pnsolici=' || pnsolici || ' pcmatric='
            || pcmatric || ' pcpostal=' || pcpostal || ' ptdomici=' || ptdomici
            || ' ptnatrie=' || ptnatrie || ' p_filtroprod=' || p_filtroprod || 'pcpolcia='
            || pcpolcia || ' pccompani= ' || pccompani || ' pcactivi= ' || pcactivi
            || ' pcestsupl= ' || pcestsupl;
      vobject        VARCHAR2(200) := 'PAC_MD_DINCARTERA.f_consulta_gestrenova';
      v_max_reg      NUMBER;
   BEGIN
      buscar :=
         buscar || ' AND ((pac_corretaje.f_tiene_corretaje (s.sseguro) = 1 AND ('
         || pac_md_common.f_get_cxtagente || ' = s.cagente OR '
         || pac_md_common.f_get_cxtagente
         || ' IN (SELECT ctj.cagente FROM age_corretaje ctj WHERE ctj.sseguro = s.sseguro)))'
         || ' OR ((s.cagente, s.cempres) IN (select aa.cagente, aa.cempres from agentes_agente_pol aa)))';

      IF NVL(psproduc, 0) <> 0 THEN
         buscar := buscar || ' and s.sproduc =' || psproduc;
      ELSE
         nerr := pac_productos.f_get_filtroprod(p_filtroprod, v_sentence);

         IF nerr <> 0 THEN
            RAISE e_object_error;
         END IF;

         IF v_sentence IS NOT NULL THEN
            buscar := buscar || ' and s.sproduc in (select p.sproduc from productos p where'
                      || v_sentence || ' 1=1)';
         END IF;

         IF pramo IS NOT NULL THEN
            buscar := buscar || ' and s.sproduc in (select p.sproduc from productos p where'
                      || ' p.cramo = ' || pramo || ' )';
         END IF;
      END IF;

      IF p_filtroprod IN('SALDAR', 'PRORROGAR') THEN
         buscar := buscar || ' and s.csituac = 0 and s.creteni = 0 ';
      END IF;

      IF p_filtroprod = 'SINIESTRO' THEN
         buscar := buscar || ' and s.csituac <> 4 ';
      END IF;

      IF pnpoliza IS NOT NULL THEN
         buscar := buscar || ' and s.npoliza = ' || CHR(39) || pnpoliza || CHR(39);
      END IF;

      IF pnsolici IS NOT NULL THEN
         buscar := buscar || ' and s.nsolici = ' || pnsolici;
      END IF;

      IF pnpolini IS NOT NULL THEN
         buscar :=
            buscar
            || ' and s.sseguro IN ( SELECT SSEGURO from CNVPOLIZAS WHERE POLISSA_INI =  '
            || CHR(39) || pnpolini || CHR(39) || ')';
      END IF;

      IF pfvencimini IS NOT NULL
         AND pfvencimfin IS NOT NULL THEN
         buscar := buscar || ' and  to_char(s.fvencim,''YYYYMMDD'')  between ('
                   || TO_CHAR(pfvencimini, 'YYYYMMDD') || ' and '
                   || TO_CHAR(pfvencimfin, 'YYYYMMDD') || ' )';
      ELSIF pfvencimini IS NOT NULL THEN
         buscar := buscar || ' and to_char(s.fvencim,''YYYYMMDD'') >= '
                   || TO_CHAR(pfvencimini, 'YYYYMMDD');
      ELSIF pfvencimfin IS NOT NULL THEN
         buscar := buscar || ' and to_char(s.fvencim,''YYYYMMDD'') <= '
                   || TO_CHAR(pfvencimfin, 'YYYYMMDD');
      END IF;

      IF pfilage = 0 THEN
         IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(), 'FILTRO_AGE'),
                0) = 1 THEN
            buscar :=
               buscar
               || ' and s.cagente in (SELECT a.cagente
                                    FROM (SELECT     LEVEL nivel, cagente
                                                FROM redcomercial r
                                               WHERE
                                                  r.fmovfin is null
                                          START WITH
                                                  r.cagente = '
               || pac_md_common.f_get_cxtagente() || ' AND r.cempres = '
               || pac_md_common.f_get_cxtempresa()
               || ' and r.fmovfin is null
                                          CONNECT BY PRIOR r.cagente =(r.cpadre + 0)
                                                 AND PRIOR r.cempres =(r.cempres + 0)
                                                 and r.fmovfin is null
                                                 AND r.cagente >= 0) rr,
                                         agentes a
                                   where rr.cagente = a.cagente)';
         END IF;
      END IF;

      IF pcpolcia IS NOT NULL THEN
         buscar := buscar || ' and upper(s.cpolcia) like ' || CHR(39) || '%' || pcpolcia
                   || '%' || CHR(39);
      END IF;

      IF NVL(pncert, -1) <> -1 THEN
         buscar := buscar || '  and s.ncertif =' || pncert;
      END IF;

      IF pcagente IS NOT NULL THEN
         buscar := buscar || ' and s.cagente = ' || pcagente;
      END IF;

      IF pcsituac IS NOT NULL THEN
         buscar := buscar || ' and s.csituac = ' || pcsituac;
      ELSIF pcpolcia IS NULL
            AND pnpoliza IS NULL
            AND pnsolici IS NULL THEN
         buscar := buscar || ' and s.csituac != 16 ';
      END IF;

      IF pcmatric IS NOT NULL THEN
         vform := ' , autriesgos aut ';
         buscar :=
            buscar || ' and aut.sseguro = s.sseguro and upper(aut.cmatric) like upper(''%'
            || pcmatric
            || '%'') and aut.nmovimi = (select max(nmovimi) from movseguro where sseguro = s.sseguro)';
      END IF;

      IF pcpostal IS NOT NULL
         OR ptdomici IS NOT NULL THEN
         vform := vform || ' , sitriesgo sit ';
      END IF;

      IF pccompani IS NOT NULL THEN
         buscar := buscar || ' and s.CCOMPANI = ' || pccompani;
      END IF;

      IF pcpostal IS NOT NULL THEN
         buscar := buscar
                   || ' and sit.sseguro = s.sseguro and upper(sit.cpostal) like upper(''%'
                   || pcpostal || '%'')';
      END IF;

      IF ptdomici IS NOT NULL THEN
         buscar := buscar
                   || ' and sit.sseguro = s.sseguro and upper(sit.tdomici) like upper(''%'
                   || ptdomici || '%'')';
      END IF;

      IF ptnatrie IS NOT NULL THEN
         vform := vform || ' , riesgos rie ';
         buscar := buscar
                   || ' and rie.sseguro = s.sseguro and upper(rie.tnatrie) like upper(''%'
                   || ptnatrie || '%'')';
      END IF;

      IF pcactivi IS NOT NULL THEN
         buscar := buscar || ' and s.cactivi = ' || pcactivi;
      END IF;

      IF pcestsupl IS NOT NULL THEN
         buscar := buscar || ' and EXISTS (SELECT 1 FROM sup_solicitud sup'
                   || ' WHERE sup.sseguro = s.sseguro and cestsup = ' || pcestsupl || ')';
      END IF;

      v_nom := ' pac_iax_listvalores.f_get_nametomador(s.sseguro, 1) ';

      IF NVL(ptipopersona, 0) > 0 THEN
         IF ptipopersona = 1 THEN   -- Prenador
            tabtp := 'TOMADORES';
         ELSIF NVL(ptipopersona, 0) = 2 THEN   -- Asegurat
            empresa := f_parinstalacion_n('EMPRESADEF');

            IF NVL(pac_parametros.f_parempresa_t(empresa, 'NOM_TOM_ASEG'), 0) = 1 THEN
               v_nom := ' f_nombre(aa.sperson, 1, s.cagente) ';
               tabtp_ase := ', ASEGURADOS aa';
            END IF;
         END IF;
      END IF;

      IF (pnnumide IS NOT NULL
          OR NVL(psnip, ' ') <> ' '
          OR pbuscar IS NOT NULL)
         AND NVL(ptipopersona, 0) > 0 THEN
         IF ptipopersona = 1 THEN   -- Prenador
            tabtp := 'TOMADORES';
         ELSIF ptipopersona = 2 THEN   -- Asegurat
            tabtp := 'ASEGURADOS';
         END IF;

         IF tabtp IS NOT NULL THEN
            subus := ' and s.sseguro IN (SELECT a.sseguro FROM ' || tabtp
                     || ' a, PERSONAS p WHERE a.sperson = p.sperson';

            IF ptipopersona = 2 THEN   -- Asegurat
               subus := subus || ' AND a.ffecfin IS NULL';
            END IF;

            IF pnnumide IS NOT NULL THEN
               --Bug 371152-21271 Busqueda de NIF minuscula KJSC 26/08/2015
               IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                                    'NIF_MINUSCULAS'),
                      0) = 1 THEN
                  subus := subus || ' AND UPPER(p.nnumnif) = UPPER(''' || pnnumide || ''')';
               ELSE
                  subus := subus || ' AND p.nnumnif = ' || CHR(39) || pnnumide || CHR(39)
                           || '';
               END IF;
            END IF;

            IF NVL(psnip, ' ') <> ' ' THEN
               subus := subus || ' AND upper(p.snip)=upper(' || CHR(39) || psnip || CHR(39)
                        || ')';
            END IF;

            IF pbuscar IS NOT NULL THEN
               nerr := f_strstd(pbuscar, auxnom);
               subus := subus || ' AND upper(p.tbuscar) like upper(''%' || auxnom || '%'
                        || CHR(39) || ')';
            END IF;

            subus := subus || ')';
         END IF;
      END IF;

      IF tabtp_ase IS NOT NULL THEN
         buscar := buscar || ' AND s.sseguro = aa.sseguro ';
      END IF;

      -- Bug 23940 - APD - 31/12/2012 - si es una poliza administrada solo se debe mostrar el ncertif = 0,
      -- para el resto de polizas mostrar todas las polizas
      buscar :=
         buscar
         --  || ' AND ( (pac_seguros.f_es_col_admin(s.sseguro) = 1 and ncertif = 0) or pac_seguros.f_es_col_admin(s.sseguro) = 0) and csituac not in ( 2,3)  ';
         -- || ' AND ( (pac_seguros.f_es_col_admin(s.sseguro) = 1 and ncertif = 0) or pac_seguros.f_es_col_agrup(s.sseguro) = 1 ) and csituac not in ( 2,3) and creteni not in (3,4) ';
         || ' AND ( (pac_seguros.f_es_col_admin(s.sseguro) = 1 and ncertif = 0) or pac_seguros.f_es_col_agrup(s.sseguro) = 1 OR (pc.autmanual = ''P''  AND ncertif = 0) OR NVL(f_parproductos_v(s.sproduc,''ADMITE_CERTIFICADOS''),0)=0) and csituac not in ( 2,3) and creteni not in (3,4) ';
      -- fin Bug 23940 - APD - 31/12/2012
      squery :=
         'SELECT pac_iax_listvalores.f_get_retencionpoliza(s.creteni) treteni,s.sseguro, to_char(s.npoliza) npoliza, s.ncertif, f_formatopolseg(s.sseguro) formato_npoliza, s.cpolcia,'
         || 'PAC_IAXPAR_PRODUCTOS.f_get_parproducto(''ADMITE_CERTIFICADOS'', s.sproduc) mostra_certif, CBLOQUEOCOL CBLOQUEO, '
         || v_nom
         || 'AS nombre, PAC_IAX_LISTVALORES.F_Get_Sit_Pol_Detalle(s.sseguro) as situacion,'
         || ' s.sproduc, f_desproducto_t(s.cramo,s.cmodali,s.ctipseg,s.ccolect,1,PAC_MD_COMMON.f_get_cxtidioma) as desproducto,'
         || ' ff_descompania(s.ccompani) ccompani, null nnumide, null cmediad, null ccolabo, s.fefecto fefecto, null csinies, s.femisio femisio, null cplan, null clinea,'
         || ' s.cactivi, ff_desactividad (s.cactivi, s.cramo, PAC_MD_COMMON.f_get_cxtidioma, 2) tactivi, '
         --|| ' ff_desagente(s.cagente) tagente FROM seguros s ' || vform || tabtp_ase || buscar
         || ' ff_desagente(s.cagente) tagente FROM prodcartera pc, seguros s ' || vform
         || tabtp_ase || buscar || subus;
      squery := squery || '  and pc.SPRODUC=s.sproduc and pc.cempres=s.cempres ';
      v_max_reg := pac_parametros.f_parinstalacion_n('N_MAX_REG');
      squery := squery || ' and rownum <= ' || v_max_reg;
      squery := squery || ' order by npoliza desc, ncertif desc nulls last';
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);

      IF pac_md_log.f_log_consultas(squery, 'PAC_MD_DINCARTERA.F_CONSULTA_GESTRENOVA', 1, 2,
                                    mensajes) <> 0 THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_consulta_gestrenova;

   -- Bug 23940 - APD - 08/11/2012 - se crea la funcion
   FUNCTION f_act_cbloqueocol(
      psseguro IN NUMBER,
      pcbloqueocol IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      num_err        NUMBER;
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                               := 'psseguro=' || psseguro || ' pcbloqueocol: ' || pcbloqueocol;
      vobject        VARCHAR2(200) := 'PAC_MD_DINCARTERA.f_act_cbloqueocol';
   BEGIN
      num_err := pac_dincartera.f_act_cbloqueocol(psseguro, pcbloqueocol);

      IF num_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_act_cbloqueocol;

   -- Bug 23940 - APD - 08/11/2012 - se crea la funcion
   FUNCTION f_suplemento_renovacion(
      psseguro IN NUMBER,
      otexto OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      num_err        NUMBER;
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'psseguro=' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_MD_DINCARTERA.f_suplemento_renovacion';
      ohaysuplem     NUMBER;
      v_fcarpro      seguros.fcarpro%TYPE;
      v_fcaranu      seguros.fcaranu%TYPE;
   BEGIN
      num_err := pac_dincartera.f_suplemento_renovacion(psseguro, ohaysuplem);

      IF num_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      SELECT fcarpro, fcaranu
        INTO v_fcarpro, v_fcaranu
        FROM seguros
       WHERE sseguro = psseguro;

      IF ohaysuplem = 0
         AND v_fcarpro = v_fcaranu THEN
         otexto := f_axis_literales(9904493);   --Póliza sin suplemento de renovación generado. ¿Desea continuar?
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_suplemento_renovacion;

   -- Bug 23940 - APD - 08/11/2012 - se crea la funcion
   FUNCTION f_botones_gestrenova(
      psseguro IN NUMBER,
      opermiteemitir OUT NUMBER,
      opermitepropret OUT NUMBER,
      opermitesuplemento OUT NUMBER,
      opermiterenovar OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      num_err        NUMBER;
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'psseguro=' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_MD_DINCARTERA.f_botones_gestrenova';
   BEGIN
      num_err := pac_dincartera.f_botones_gestrenova(psseguro, opermiteemitir,
                                                     opermitepropret, opermitesuplemento,
                                                     opermiterenovar);

      IF num_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_botones_gestrenova;

   FUNCTION f_get_carteradiaria_poliza(pnpoliza IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vresult        NUMBER;
      vsproduc       NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_DINCARTERA.f_get_carteradiaria_poliza';
   BEGIN
      IF pnpoliza IS NULL THEN
         RAISE e_object_error;
      END IF;

      BEGIN
         SELECT sproduc
           INTO vsproduc
           FROM seguros
          WHERE npoliza = pnpoliza
            AND ROWNUM = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9904077);
            RAISE e_object_error;
      END;

      vresult := pac_mdpar_productos.f_get_parproducto('CARTERA_DIARIA', vsproduc);
      RETURN vresult;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_carteradiaria_poliza;

   FUNCTION f_get_carteraprog_poliza(pnpoliza IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vresult        NUMBER;
      vsproduc       NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_DINCARTERA.f_get_carteraprog_poliza';
   BEGIN
      IF pnpoliza IS NULL THEN
         RAISE e_object_error;
      END IF;

      BEGIN
         SELECT sproduc
           INTO vsproduc
           FROM seguros
          WHERE npoliza = pnpoliza
            AND ROWNUM = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9904077);
            RAISE e_object_error;
      END;

      vresult := pac_mdpar_productos.f_get_parproducto('CARTERA_PROGRAMADA', vsproduc);
      RETURN vresult;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_carteraprog_poliza;

   FUNCTION f_programar_cartera(
      psproces IN NUMBER,
      pmodo IN VARCHAR2,
      pcempres IN NUMBER,
      pmes IN NUMBER,
      panyo IN NUMBER,
      pproductos IN VARCHAR2,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      psprocar IN NUMBER,
      pfejecucion IN DATE,
      pfcartera IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psproces=' || psproces || ' pcempres =' || pcempres || ' pmes=' || pmes
            || ' panyo =' || panyo || ' pproductos =' || pproductos || ' pnpoliza ='
            || pnpoliza || ' pmodo =' || pmodo || ' psprocar =' || psprocar
            || ' pfejecucion =' || pfejecucion || ' pfcartera =' || pfcartera;
      vobject        VARCHAR2(200) := 'PAC_MD_DINCARTERA.F_PROGRAMAR_CARTERA';
      vnumerr        NUMBER;
      pfperini       DATE;
      vmens          VARCHAR2(250);
      vcarterabatch  NUMBER := 0;
      --pmodo          VARCHAR(20);
      v_plsql        VARCHAR2(1000);
      v_params_job   VARCHAR(2000);   --Mantis  35695-210153 - BLA - DD24/MM07/2015. se incrementa el tamaño variable
      v_fecha_ejecucion VARCHAR2(2000);   --Mantis  35695-210153 - BLA - DD24/MM07/2015. - se adiciona variable
   BEGIN
      -- Control parametros entrada
      --Si la fecha de cartera es null, tiene que haber algo tanto en ANYO como en MES
      IF pfcartera IS NULL
         AND(panyo IS NULL
             OR pmes IS NULL) THEN
         RAISE e_param_error;
      END IF;

      IF psproces IS NULL
         --OR pproductos IS NULL
         OR pcempres IS NULL
         --OR pmes IS NULL
         --OR panyo IS NULL
         OR pfejecucion IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pfcartera IS NULL THEN
         pfperini := TO_DATE('01/' || TO_CHAR(pmes) || '/' || TO_CHAR(panyo), 'dd/mm/yyyy');
      ELSE
         pfperini := pfcartera;
      END IF;

      vpasexec := 2;

      DECLARE
         FUNCTION f_nulos(p_camp IN VARCHAR2, p_tip IN NUMBER DEFAULT 1)
            RETURN VARCHAR2 IS
         BEGIN
            vpasexec := 31;

            IF p_camp IS NULL THEN
               RETURN ' null';
            ELSE
               IF p_tip = 2 THEN
                  RETURN ' to_date(' || CHR(39) || CHR(39) || p_camp || CHR(39) || CHR(39)
                         || ',''''ddmmyyyy'''')';
               ELSE
                  RETURN ' ' || p_camp;
               END IF;
            END IF;
         END;
      BEGIN
         vpasexec := 3;
         --JLV 29/05/2013 para no perder el usuario
         v_plsql :=
            'DECLARE ' || CHR(10) || '   num_err  NUMBER; ' || CHR(10)
            || '   result   NUMBER; ' || CHR(10) || '   mensajes VARCHAR2(200); ' || CHR(10)
            || 'BEGIN ' || CHR(10) || CHR(10)
            || '   num_err:= pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t('
            || f_nulos(pcempres) || ', ''''USER_BBDD''''));' || CHR(10)
            || '   result := pac_dincartera.f_lanza_cartera(' || f_nulos(psproces) || ','
            || CHR(39) || CHR(39) || pmodo || CHR(39) || CHR(39) || ',' || f_nulos(pcempres)
            || ',' || CHR(39) || CHR(39) || pproductos || CHR(39) || CHR(39) || ','
            || f_nulos(pnpoliza) || ',' || f_nulos(pncertif) || ','
            || f_nulos(TO_CHAR(pfperini, 'ddmmyyyy'), 2) || ','
            || f_nulos(TO_CHAR(pfcartera, 'ddmmyyyy'), 2) || ',' || ' '
            || f_nulos(f_parinstalacion_n('MONEDAINST')) || ','
            || f_nulos(pac_md_common.f_get_cxtidioma) || ',' || f_nulos(psprocar)
            || ',mensajes); ' || CHR(10) || CHR(10) || 'END;';
         --Mantis  35695-210153 - inicio - BLA - DD24/MM07/2015.
         v_fecha_ejecucion := 'TO_DATE(' || CHR(39) || TO_CHAR(pfejecucion, 'dd/mm/yy') || ' '
                              || NVL(pac_parametros.f_parempresa_t(pcempres,
                                                                   'HORA_JOB_CARTERA'),
                                     '00:00')
                              || CHR(39) || ',' || '''' || 'dd/mm/yy hh24:MI' || '''' || ')';
         v_params_job := 'NEXT_DATE;' || v_fecha_ejecucion;
         --Mantis  35695-210153 -Fin- BLA - DD24/MM07/2015.
         vpasexec := 5;
         vnumerr := pac_jobs.f_ejecuta_job(NULL, v_plsql, v_params_job);
         vpasexec := 6;

         IF vnumerr <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);   -- error interno.
            RAISE e_object_error;
         END IF;

         vpasexec := 7;
         pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes, 2, NULL,
                                              f_axis_literales(9000493,
                                                               pac_md_common.f_get_cxtidioma)
                                              || ' : ' || psproces || '.'
                                              || f_axis_literales
                                                                 (9905059,
                                                                  pac_md_common.f_get_cxtidioma));
         vpasexec := 8;

         IF vnumerr > 0 THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, ' men=' || vnumerr);
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 6, vnumerr);
            RETURN 1;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam || ' men=' || vnumerr,
                        SQLCODE || ' ' || SQLERRM);
            pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                              psqcode => SQLCODE, psqerrm => SQLERRM);
            RETURN 1;
      END;

      -- Bug 26209  FAC - FIN 27/02/2013 - Solución definitiva ejecución de cartera desde pantalla
      RETURN vnumerr;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_programar_cartera;

   FUNCTION f_lanza_cartera_cero(
      pcempres IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      psproces OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
            := 'pcempres=' || pcempres || ' pnpoliza=' || pnpoliza || ' pncertif=' || pncertif;
      vobject        VARCHAR2(200) := 'PAC_MD_DINCARTERA.f_lanza_cartera_cero';
      vnumerr        NUMBER;
      v_mes          NUMBER;
      v_anyo         NUMBER;
      v_nproceso     NUMBER;
      v_fperini      DATE;
      vmens          VARCHAR2(250);
   BEGIN
      IF pcempres IS NULL
         OR pnpoliza IS NULL
         OR pncertif IS NULL THEN
         RAISE e_param_error;
      END IF;

      SELECT TO_NUMBER(TO_CHAR(fcarpro, 'mm')), TO_NUMBER(TO_CHAR(fcarpro, 'yyyy'))
        INTO v_mes, v_anyo
        FROM seguros
       WHERE npoliza = pnpoliza
         AND ncertif = pncertif;

      vnumerr := pac_md_dincartera.f_registra_proceso('CARTERA', v_mes, v_anyo, pcempres, NULL,   --fcartera
                                                      v_nproceso, mensajes);
      v_fperini := TO_DATE('01/' || TO_CHAR(v_mes) || '/' || TO_CHAR(v_anyo), 'dd/mm/yyyy');

      SELECT sprocar.NEXTVAL
        INTO psproces
        FROM DUAL;

      vnumerr := pac_dincartera.f_ejecutar_cartera(v_nproceso, 'CARTERA', pcempres, pnpoliza,
                                                   v_fperini, NULL, pncertif,
                                                   f_parinstalacion_n('MONEDAINST'),
                                                   pac_md_common.f_get_cxtidioma, psproces,
                                                   NULL, vmens, 1);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);   -- error interno.
         RAISE e_object_error;
      END IF;

      --CAMBIAR MENSAJE
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, NULL,
                                           f_axis_literales(9000493,
                                                            pac_md_common.f_get_cxtidioma)
                                           || ' : ' || v_nproceso || '.'
                                           || f_axis_literales(9905059,
                                                               pac_md_common.f_get_cxtidioma));
      RETURN vnumerr;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      --Se debe crear un mensaje con el número de pólizas tratadas (índice), pólizas tratadas con error (índice error) y
      -- el código del proceso.
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_lanza_cartera_cero;

   FUNCTION f_retroceder_cartera_cero(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro=' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_IAX_DINCARTERA.f_retroceder_cartera_cero';
      vnumerr        NUMBER;
      v_fcaranu      DATE;
      v_cmotmov      NUMBER;
      v_nmovimi      NUMBER;
      n_sup          NUMBER;
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      SELECT cmotmov, nmovimi
        INTO v_cmotmov, v_nmovimi
        FROM movseguro
       WHERE sseguro = psseguro
         AND nmovimi = (SELECT MAX(nmovimi)
                          FROM movseguro m2
                         WHERE m2.sseguro = movseguro.sseguro)
         AND cmovseg = 2;

      SELECT MAX(nsuplem)
        INTO n_sup
        FROM movseguro
       WHERE sseguro = psseguro
         AND nmovimi = v_nmovimi;

      vnumerr := pk_rechazo_movimiento.f_rechazo(psseguro, v_cmotmov, n_sup, 2,
                                                 'Rechazo automático - Renovación cero',
                                                 v_nmovimi, 1);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);   -- error interno.
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      --Se debe crear un mensaje con el número de pólizas tratadas (índice), pólizas tratadas con error (índice error) y
      -- el código del proceso.
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_retroceder_cartera_cero;

      /*********************************************************************************************************
       Funcio que realitza les validacions per a la renovació de la cartera.


         psproces  NUMBER,
         pcempres  NUMBER,
         pmes      NUMBER,
         panyo     NUMBER,
         pnpoliza  NUMBER,
         pncertif  NUMBER,
         psprocar  NUMBER,
         pfcartera DATE,
         mensajes  t_iax_mensajes
   *********************************************************************************************************/
   FUNCTION f_validacion_cartera(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pmes IN NUMBER,
      panyo IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      psprocar IN NUMBER,
      pfcartera IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vfcaranu       DATE;
      vfcarpro       DATE;
      vdatarenova    DATE := TO_DATE('01/' || pmes || '/' || panyo, 'dd/mm/yyyy');
      vnumlin        NUMBER := NULL;
      vobject        VARCHAR2(100) := 'PAC_MD_DINCARTERA.f_validacion_cartera';
      vparam         VARCHAR2(1000)
                             := 'psproces:' || psproces || 'mes:' || pmes || 'panyo:' || panyo;
      vpasexec       NUMBER := 1;
   BEGIN
      SELECT fcarpro, fcaranu
        INTO vfcarpro, vfcaranu
        FROM seguros
       WHERE npoliza = pnpoliza;

      IF TRUNC(vfcarpro) < TRUNC(vfcaranu) THEN
         IF TRUNC(vdatarenova) > TRUNC(vfcaranu) THEN
            vnumerr := f_proceslin(psproces, SUBSTR(f_axis_literales(9901777), 1, 120), 0,
                                   vnumlin);
            vnumerr := f_procesfin(psproces, vnumerr);
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9901777);
            RETURN -99;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_validacion_cartera;
END pac_md_dincartera;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_DINCARTERA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_DINCARTERA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_DINCARTERA" TO "PROGRAMADORESCSI";
