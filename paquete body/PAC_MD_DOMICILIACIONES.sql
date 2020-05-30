--------------------------------------------------------
--  DDL for Package Body PAC_MD_DOMICILIACIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_DOMICILIACIONES" AS
/******************************************************************************
   NOMBRE:       PAC_MD_DOMICILIACIONES
   PROPÓSITO:  Mantenimiento domiciliaciones. gestión

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        27/02/2009   XCG                1. Creación del package.
   2.0        08/04/2010   MCA                2. Corregir validación de parámetros de entrada
   3.0        10/06/2010   PFA                3. 14401: MDP003 - Consulta proceso domiciliaciones
   4.0        27/08/2010   FAL                4. 0015750: CRE998 - Modificacions mòdul domiciliacions
   5.0        19/07/2011   JMP                5. 0018825: LCOL_A001- Modificacion de la pantalla de domiciliaciones
   6.0        09/02/2012   APD                6. 0021116: LCOL_A001-Controlar domiciliaciones y prenotificaciones por cobrador bancario
   7.0        03/04/2012   JGR                7. 0021718: MDP_A001-Domiciliaciones: modificaciones generales - 0111176
   8.0        16/05/2012   JGR                8. 0022268: LCOL_A001-Revision circuito domiciliaciones - 0114762 + 0114943
   9.0        03/04/2012   JGR                9. 0021718: MDP_A001-Domiciliaciones: modificaciones generales - 0111176
   10.0       26/06/2013   JDS                10.0027150: LCOL_A003-Corregir lista de incidencia reportadas en QT-6200
 ******************************************************************************/

   /**************************************************************************
        Función que inserta las domiciliaciones
        PARAM IN PSPROCES   : nº proceso de domiciliación
        PARAM IN PCEMPRES   : nº empresa
        PARAM IN PEFECTO    : fecha efecto límite de recibos
        PARAM IN PFFECCOB   : fecha de remesea de la domiciliación
        PARAM IN PCRAMO     : nº ramo
        PARAM IN PSPRODUC   : nº producto
        PARAM IN PSPRODOM   : nº proceso selección productos a domiciliar
        PARAM IN PIDIOMA   : idioma
        PARAM OUT PNOK      : nº recibos domiciliados correctamente
        PARAM OUT PNKO      : nº recibos domiciliados incorrectamente
            NomMap1 OUT VARCHAR2, --Path Completo Fichero de map 312,
            NomMap2 OUT VARCHAR2, --Path Completo Fichero de map 312,
            NomDR OUT VARCHAR2,   --Path Completo Fichero de DR,
        PARAM OUT mensaje    : Tratamiento del mensaje
        PARAM OUT NERROR     : Código de error (0: opración correcta sino error)
   *************************************************************************/
   FUNCTION f_domiciliar(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pfefecto IN DATE,
      pffeccob IN DATE,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      -- Bug 15750 - FAL - 27/08/2010 - Permitir seleccionar varios productos en el proceso domiciliación
      psprodom IN NUMBER,
      -- FI Bug 15750 - FAL - 27/08/2010 - Permitir seleccionar varios productos en el proceso domiciliación
      -- BUG 18825 - 19/07/2011 - JMP
      pccobban IN NUMBER,
      pcbanco IN NUMBER,
      pctipcta IN NUMBER,
      pfvtotar IN VARCHAR2,
      pcreferen IN VARCHAR2,
      pdfefecto IN DATE,
      -- FIN BUG 18825 - 19/07/2011 - JMP
      --BUG 23645 - 07/09/2012 - JTS
      pcagente IN NUMBER,
      ptagente IN VARCHAR2,
      pnnumide IN VARCHAR2,
      pttomador IN VARCHAR2,
      pnrecibo IN NUMBER,
      --FI BUG 23645
      pnok OUT NUMBER,
      pnko OUT NUMBER,
      sproces OUT NUMBER,
      nommap1 OUT VARCHAR2,   --Path Completo Fichero de map 312,
      nommap2 OUT VARCHAR2,   --Path Completo Fichero de map 312,
      nomdr OUT VARCHAR2,   --Path Completo Fichero de DR
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_md_domiciliaciones.f_domiciliar';
      vparam         VARCHAR2(500)
                          := 'parámetros - pcempres ' || pcempres || ' pfefecto ' || pfefecto;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vsqlstmt       VARCHAR2(2000);
      vrefcursor     sys_refcursor;
      v_user         cfg_user.cuser%TYPE;
      smapead        NUMBER;
      vpath          VARCHAR2(100);
      v_missatge     VARCHAR2(100);
      v_dias         parempresas.nvalpar%TYPE;   --NUMBER;
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF psproces IS NOT NULL
         AND(pcramo IS NOT NULL   -- pcempres IS NOT NULL  OR   BUG 14040
             OR psproduc IS NOT NULL
             OR pfefecto IS NOT NULL) THEN
         vparam := 'Parámetro - Proceso';
         RAISE e_error_controlat;
      END IF;

      IF ((pcempres IS NULL
           AND pfefecto IS NULL)
          OR(pcempres IS NULL
             AND pfefecto IS NOT NULL)
          OR(pcempres IS NOT NULL
             AND pfefecto IS NULL))
         AND psproces IS NULL THEN
         vparam := 'Parámetro - Empresa';
         RAISE e_error_controlat;
      END IF;

      BEGIN
         SELECT NVL(nvalpar, 0)
           INTO v_dias
           FROM parempresas
          WHERE cparam = 'DIASDOMICI'
            AND cempres = pcempres;
      EXCEPTION
         WHEN OTHERS THEN
            -- No esta el parametro definido
            NULL;
      END;

      IF v_dias IS NOT NULL
         AND   --si es null aleshores no tinc limitació.
            TO_DATE(TO_CHAR(pfefecto, 'dd/mm/yyyy'), 'dd/mm/yyyy') >
                               TO_DATE(TO_CHAR(f_sysdate + v_dias, 'dd/mm/yyyy'), 'dd/mm/yyyy') THEN
         vparam := 'Parámetro - Fefecto';
         RAISE e_error_controlat;
      END IF;

      -- Bug 21116 - APD - 09/02/2012 - el cobrador bancario es obligatorio
      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'DOMI_COBBAN'), 0) = 1 THEN
         IF pccobban IS NULL THEN
            vparam := 'Parámetro - Cobban';
            RAISE e_error_controlat;
         ELSE
            -- Bug 21116 - APD - 27/01/2012 - Controlar que si existe una domiciliación
            -- en curso para un cobrador bancario, no permitir realizar una nueva
            -- domiciliación de este cobrador bancario (0.-No controlar, 1.-Si controlar)

            -- 8. 0022268: LCOL_A001-Revision circuito domiciliaciones - 0114762 + 0114943 - Inicio
            -- vnumerr := pac_domis.f_valida_domi_cobban(pcempres, pccobban);
            vnumerr := pac_domis.f_valida_domi_cobban(pcempres, pccobban, NULL, psproces);

            -- 8. 0022268: LCOL_A001-Revision circuito domiciliaciones - 0114762 + 0114943 - Fin
            IF vnumerr <> 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes, 1, 0,
                                              f_axis_literales(vnumerr,
                                                               pac_iax_common.f_get_cxtidioma));
               RETURN vnumerr;
            END IF;
         -- fin Bug 21116 - APD - 27/01/2012
         END IF;
      END IF;

      -- fin Bug 21116 - APD - 09/02/2012
      vnumerr :=
         pac_domiciliaciones.f_domiciliar
                                     (psproces, pcempres, pfefecto, pffeccob, pcramo, psproduc,
                                      psprodom,   -- Bug 15750 - FAL - 27/08/2010. Añade psprodom
                                      pccobban, pcbanco, pctipcta, pfvtotar, pcreferen,
                                      pdfefecto, pcagente, ptagente, pnnumide, pttomador,
                                      pnrecibo, pac_md_common.f_get_cxtidioma, pnok, pnko,
                                      vpath, nommap1, nommap2, nomdr, sproces);

      IF vnumerr = 0
         AND psproces IS NULL THEN
         --Procés generat
         pac_iobj_mensajes.crea_nuevo_mensaje
                                           (mensajes, 2, 0,
                                            f_axis_literales(9001242,
                                                             pac_iax_common.f_get_cxtidioma)
                                            || ' ' || sproces);
         --Número de rebuts cobrats
         pac_iobj_mensajes.crea_nuevo_mensaje
                                           (mensajes, 2, 0,
                                            f_axis_literales(9001243,
                                                             pac_iax_common.f_get_cxtidioma)
                                            || ' ' || pnok);
         --Número de rebuts amb errors
         pac_iobj_mensajes.crea_nuevo_mensaje
                                           (mensajes, 2, 0,
                                            f_axis_literales(9001244,
                                                             pac_iax_common.f_get_cxtidioma)
                                            || ' ' || pnko);
         --El fitxer de domiciliacions s''ha generat correctament en la ubicació:
         pac_iobj_mensajes.crea_nuevo_mensaje
                                           (mensajes, 2, 0,
                                            f_axis_literales(9001245,
                                                             pac_iax_common.f_get_cxtidioma)
                                            || ' ' || vpath);
      ELSIF vnumerr = 0
            AND psproces IS NOT NULL THEN
         --El fitxer de domiciliacions s''ha generat correctament en la ubicació:
         pac_iobj_mensajes.crea_nuevo_mensaje
                                           (mensajes, 2, 0,
                                            f_axis_literales(9001245,
                                                             pac_iax_common.f_get_cxtidioma)
                                            || ' ' || vpath);
      ELSIF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes, 1, 0,
                                              f_axis_literales(vnumerr,
                                                               pac_iax_common.f_get_cxtidioma));
         RETURN vnumerr;
      END IF;

      --Retorn del menú de l'aplicació.
      RETURN 0;
   EXCEPTION
      WHEN e_error_controlat THEN
         IF vparam = 'Parámetro - Proceso' THEN
            pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes, 1, 0,
                                              f_axis_literales(9001139,
                                                               pac_iax_common.f_get_cxtidioma));
            RETURN 9001139;
         ELSIF vparam = 'Parámetro - Empresa' THEN
            pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes, 1, 0,
                                              f_axis_literales(9001138,
                                                               pac_iax_common.f_get_cxtidioma));
            RETURN 9001138;
         ELSIF vparam = 'Parámetro - Fefecto' THEN
            v_missatge := pac_iobj_mensajes.f_get_descmensaje(109208,
                                                              pac_md_common.f_get_cxtidioma);

            IF v_dias > 0 THEN
               v_missatge :=
                  v_missatge || '+' || TO_CHAR(v_dias) || ' '
                  || pac_iobj_mensajes.f_get_descmensaje(9002204,
                                                         pac_md_common.f_get_cxtidioma);
            END IF;

            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 109208, v_missatge);   -- La fecha no puede ser superior a la actual
            RETURN 109208;
         -- Bug 21116 - APD - 09/02/2012 - el cobrador bancario es obligatorio
         ELSIF vparam = 'Parámetro - Cobban' THEN
            pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes, 1, 0,
                                              f_axis_literales(120081,
                                                               pac_iax_common.f_get_cxtidioma));
            RETURN 120081;
         -- fin Bug 21116 - APD - 09/02/2012
         END IF;
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN vnumerr;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN vnumerr;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vnumerr;
   END f_domiciliar;

/**************************************************************************
        Función que se retorna la información de domiciliaciones
        PARAM IN PSPROCES   : nº proceso de domiciliación
        PARAM IN PCEMPRES   : nº empresa
        PARAM IN PCRAMO     : nº ramo
        PARAM IN PSPRODUC   : nº producto
        PARAM IN PEFECTO    : fecha efecto límite de recibos
        PARAM IN PSPRODOM   : nº proceso selección productos a domiciliar
        PARAM IN PCCOBBAN   : Código de cobrador bancario
        PARAM IN PCBANCO    : Código de banco
        PARAM IN PCTIPCTA   : Tipo de cuenta
        PARAM IN PFVTOTAR   : Fecha de vencimiento tarjeta
        PARAM IN PCREFEREN  : Código de referencia
        PARAM OUT mensaje    : Tratamiento del mensaje
   *************************************************************************/
   FUNCTION f_get_domiciliacion(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pfefecto IN DATE,
      -- Bug 15750 - FAL - 27/08/2010 - Permitir seleccionar varios productos en el proceso domiciliación
      psprodom IN NUMBER,
      -- FI Bug 15750 - FAL - 27/08/2010
      -- BUG 18825 - 19/07/2011 - JMP
      pccobban IN NUMBER DEFAULT NULL,
      pcbanco IN NUMBER DEFAULT NULL,
      pctipcta IN NUMBER DEFAULT NULL,
      pfvtotar IN VARCHAR2 DEFAULT NULL,
      pcreferen IN VARCHAR2 DEFAULT NULL,
      pdfefecto IN DATE DEFAULT NULL,
      -- FIN BUG 18825 - 19/07/2011 - JMP
      pcagente IN NUMBER DEFAULT NULL,   -- Código Mediador -- 6. 0021718 / 0111176 - Inicio
      ptagente IN VARCHAR2 DEFAULT NULL,   -- Nombre Mediador
      pnnumide IN VARCHAR2 DEFAULT NULL,   -- Nif Tomador
      pttomador IN VARCHAR2 DEFAULT NULL,   -- Nombre Tomador
      pnrecibo IN NUMBER DEFAULT NULL,   -- Recibo -- 6. 0021718 / 0111176 - Fin
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'pac_md_domiciliaciones.f_get_domiciliacion';
      vparam         VARCHAR2(50);
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vsquery        VARCHAR2(2000);
      vsquery_total  VARCHAR2(9000);
      vrefcursor     sys_refcursor;
      ---
      vnum_dades     NUMBER(9) := 0;
      vsseguro       seguros.sseguro%TYPE;
      vempresa       VARCHAR2(400);
      vproducto      VARCHAR2(100);
      vnpoliza       VARCHAR2(20);   --(8);
      vnrecibo       NUMBER;   --(9);
      vtipo_recibo   VARCHAR2(100);
      vctipban_cobra NUMBER(1);
      vcobrador      VARCHAR2(100);
      vfefecto       DATE;
      vfvencim       DATE;
      vctipban_cban  NUMBER;   --(1);
      vcbancar       VARCHAR2(40);
      vitotalr       NUMBER;   --(15,2);
      vproceso       NUMBER;   --(100);
      vfichero       VARCHAR2(500);
      -- BUG 18825 - 19/07/2011 - JMP
      v_estado       detvalores.tatribu%TYPE;
      v_estdomi      detvalores.tatribu%TYPE;
      v_festado      DATE;
      v_testimp      VARCHAR2(500);
      -- FIN BUG 18825 - 19/07/2011 - JMP
      vtomador       VARCHAR2(200);
      vcodbancar     VARCHAR2(200);
      vcont          NUMBER := 0;   -- BUG 14401
      v_max_reg      parinstalacion.nvalpar%TYPE;   --PFA
      vmsg           VARCHAR2(500);   -- Mostrar mensaje en pantalla si está limitado
      vcramo         NUMBER;
      vcempres       NUMBER;
      vsproduc       NUMBER;
      vsproduc       NUMBER;
      -- 7. 03/04/2012 JGR 0021718/0111176 MDP_A001 - Inicio
      vcagente       recibos.cagente%TYPE;
      vtagente       VARCHAR2(500);
      vnanuali       recibos.nanuali%TYPE;
      vnfracci       recibos.nfracci%TYPE;
      --22080
      vfrecaudo      DATE;
      vfrechazo      DATE;
      vcdevrec       devbanrecibos.cdevrec%TYPE;

      -- 7. 03/04/2012 JGR 0021718/0111176 MDP_A001 - Fin

      -- Bug 15750 - FAL - 27/08/2010 - Permitir seleccionar varios productos en el proceso domiciliación
      CURSOR c_prod IS
         SELECT *
           FROM tmp_domisaux
          WHERE sproces = psprodom
            AND cestado = 1;
   -- FI Bug 15750 - FAL - 23/08/2010
   BEGIN
      v_max_reg := f_parinstalacion_n('N_MAX_REG');   -- BUG 14401  PFA   Mostrar mensaje en pantalla si está limitado

      --CONTROL DE PARAMETROS DE ENTRADA
       --Comprovació de paràmetres d'entrada
      IF psproces IS NULL
         AND pfefecto IS NULL THEN
         vparam := 'Parámetro - Fecha Efecto nulo';
         RAISE e_error_controlat;
      END IF;

      IF psproces IS NOT NULL
         AND(pcramo IS NOT NULL   --pcempres IS NOT NULL  OR   bug 14040
             OR psproduc IS NOT NULL
             OR pfefecto IS NOT NULL) THEN
         vparam := 'Parámetro - Proceso';
         RAISE e_error_controlat;
      END IF;

      -- Bug 21116 - APD - 09/02/2012 - el cobrador bancario es obligatorio
      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'DOMI_COBBAN'), 0) = 1 THEN
         IF pccobban IS NULL THEN
            vparam := 'Parámetro - Cobban';
            RAISE e_error_controlat;
         END IF;
      END IF;

      -- fin Bug 21116 - APD - 09/02/2012
      vnumerr :=
         pac_domiciliaciones.f_get_domiciliacion
                                         (psproces, pcempres, pcramo, psproduc, pfefecto,
                                          pac_md_common.f_get_cxtidioma, vsquery_total,
                                          psprodom,
                                          -- BUG 18825 - 19/07/2011 - JMP
                                          pccobban, pcbanco, pctipcta, pfvtotar, pcreferen,
                                          pdfefecto   -- );   -- FIN BUG 18825 - 19/07/2011 - JMP
                                                   ,
                                          pcagente, ptagente, pnnumide, pttomador, pnrecibo);   -- 6. 0021718 / 0111176

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      vrefcursor := pac_md_listvalores.f_opencursor(vsquery_total, mensajes);

       /*--CONTROLAR QUE HAYAN DATOS
       IF vrefcursor IS NOT NULL THEN
          FETCH vrefcursor
           INTO vempresa, vproducto, vnpoliza, vnrecibo, vtipo_recibo, vctipban_cobra,
                vcobrador, vfefecto, vfvencim, vctipban_cban, vcbancar, vitotalr, vproceso,
                vfichero;*/
      -- OPEN vrefcursor FOR vsquery;
      IF vrefcursor IS NOT NULL THEN
         -- BUG 14401  PFA   Mostrar mensaje en pantalla si está limitado
         LOOP
            FETCH vrefcursor
             INTO vsseguro, vempresa, vproducto, vcodbancar, vcobrador, vnrecibo, vnpoliza,
                  vtipo_recibo, vtomador, vfefecto, vfvencim, vcbancar, vitotalr,
                  vctipban_cban, vcbancar, vproceso, vfichero,
                                                              -- BUG 18825 - 19/07/2011 - JMP
                                                              v_estado, v_testimp, v_estdomi,
                  v_festado
                           -- FIN BUG 18825 - 19/07/2011 - JMP
                  , vcagente, vtagente, vnanuali, vnfracci,   -- 7. 03/04/2012 JGR 0021718/0111176 MDP_A001
                                                           vfrecaudo, vfrechazo, vcdevrec;

            vcont := vcont + 1;
            EXIT WHEN vrefcursor%NOTFOUND;
         END LOOP;

--         FETCH vrefcursor
--          INTO vempresa, vproducto, vcodbancar, vcobrador, vnrecibo, vnpoliza, vtipo_recibo,
--               vtomador, vfefecto, vfvencim, vcbancar, vitotalr, vctipban_cban, vcbancar,
--               vproceso, vfichero;
       --Fi BUG 14401  PFA   Mostrar mensaje en pantalla si está limitado

         --Si el cursor no te dades
         IF vempresa IS NULL THEN
            IF vrefcursor%ISOPEN THEN
               CLOSE vrefcursor;
            END IF;

            IF psproces IS NULL THEN
               pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes, 2, 0,
                                              f_axis_literales(9001249,
                                                               pac_iax_common.f_get_cxtidioma));   --No hi han rebuts pendents de domiciliar
            ELSE
               pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes, 2, 0,
                                              f_axis_literales(103778,
                                                               pac_iax_common.f_get_cxtidioma));   --Procés inexitent
            END IF;
         END IF;

         -- BUG 14401  PFA   Mostrar mensaje en pantalla si está limitado
         IF vcont >(v_max_reg + 1) THEN
            vmsg := f_axis_literales(9901234, pac_iax_common.f_get_cxtidioma);
            vmsg := REPLACE(vmsg, '{0}', v_max_reg);
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 0, vmsg);
         END IF;

         -- Fi BUG 14401  PFA   Mostrar mensaje en pantalla si está limitado

         --INICIALIZAR DE NUEVO
         vrefcursor := pac_md_listvalores.f_opencursor(vsquery_total, mensajes);
         RETURN vrefcursor;
      ELSE
         RETURN NULL;
      END IF;
   EXCEPTION
      WHEN e_error_controlat THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         IF vparam = 'Parámetro - Proceso' THEN
            pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes, 1, 0,
                                              f_axis_literales(9001139,
                                                               pac_iax_common.f_get_cxtidioma));
         -- Bug 21116 - APD - 09/02/2012 - el cobrador bancario es obligatorio
         ELSIF vparam = 'Parámetro - Cobban' THEN
            pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes, 1, 0,
                                              f_axis_literales(120081,
                                                               pac_iax_common.f_get_cxtidioma));
         -- fin Bug 21116 - APD - 09/02/2012
         ELSE
            pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes, 1, 0,
                                              f_axis_literales(9001140,
                                                               pac_iax_common.f_get_cxtidioma));
         END IF;

         RETURN vrefcursor;
      WHEN e_param_error THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN vrefcursor;
      WHEN e_object_error THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;   --vrefcursor;
      WHEN OTHERS THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_domiciliacion;

   -- Bug 15750 - FAL - 27/08/2010 - Permitir seleccionar productos en el proceso domiciliación
   /*******************************************************************************
   FUNCION F_SET_PRODDOMIS
   Función que inserta los productos seleccionados para realizar la domiciliación en el proceso.
    Parámetros:
     Pcempres  NUMBER : Id. empresa
     Psproces  NUMBER : ID.
     Psproduc  NUMBER : Id. producto
     Pseleccio NUMBER : Valor seleccionado
    Salida :
     Mensajes  T_IAX_MENSAJES

    Retorna: un NUMBER con el id de error.
   ********************************************************************************/
   FUNCTION f_set_proddomis(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      psproduc IN NUMBER,
      pseleccio IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'Pcempres=' || pcempres || ' Psproces=' || psproces || 'Psproduc=' || psproduc
            || ' Pseleccio=' || pseleccio;
      vobject        VARCHAR2(200) := 'PAC_MD_DOMICILIACIONES.F_SET_PRODDOMIS';
      vnumerr        NUMBER;
   BEGIN
      IF pcempres IS NULL
         OR psproces IS NULL
         OR psproduc IS NULL
         OR pseleccio IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Esta función llamará a la función pac_dincartera.f_insert_tmp_carteraux.
      vnumerr := pac_domis.f_insert_tmp_domisaux(pcempres, psproces, psproduc, pseleccio);

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
   END f_set_proddomis;

-- FI Bug 15750 - FAL - 27/08/2010 - Permitir seleccionar productos en el proceso domiciliación

   /*************************************************************************
    --6. 0021718: MDP_A001-Domiciliaciones: modificaciones generales - 0111176

          Funcion en capa MD para obtener los datos de la cabecera de domiciliaciones
          param in psproces   : Código de proceso (número de remesa)
          param in pcempres   : Código de empresa
          param in pccobban   : Código de cobrador bancario
          param in pfinirem   : Fecha inicio remesa
          param in pffinrem   : Fecha fin remesa
          param out mensaje   : Tratamiento del mensaje
          return           : 0 indica cambio realizado correctamente
                             <> 0 indica error
   *************************************************************************/
   FUNCTION f_get_domiciliacion_cab(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pccobban IN NUMBER,
      pfinirem IN DATE,
      pffinrem IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'pac_md_domiciliaciones.f_get_domiciliacion_cab';
      vparam         VARCHAR2(50);
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vsquery        VARCHAR2(2000);
      vsquery_total  VARCHAR2(9000);
      vrefcursor     sys_refcursor;
      ---
      vnum_dades     NUMBER(9) := 0;
      vempresa       VARCHAR2(400);
      vsproduc       productos.sproduc%TYPE;
      vcempres       domiciliaciones_cab.cempres%TYPE;
      vsproces       domiciliaciones_cab.sproces%TYPE;
      vccobban       domiciliaciones_cab.ccobban%TYPE;
      vfcreacion     domiciliaciones_cab.fefecto%TYPE;
      vtfileenv      domiciliaciones_cab.tfileenv%TYPE;
      vtfiledev      domiciliaciones_cab.tfiledev%TYPE;
      vcremban       domiciliaciones_cab.cremban%TYPE;
      vcusumod       domiciliaciones_cab.cusumod%TYPE;
      vfusumod       domiciliaciones_cab.fusumod%TYPE;
      vsdevolu       domiciliaciones_cab.sdevolu%TYPE;
      vcestdom       domiciliaciones_cab.cestdom%TYPE;
      vtcobban       cobbancario.descripcion%TYPE;
      vfdebito       domiciliaciones.fdebito%TYPE;
      vtcompany      VARCHAR2(400);
      vremesados     NUMBER;
      viremesados    NUMBER;
      vcobrados      NUMBER;
      vicobrados     NUMBER;
      vimpagados     NUMBER;
      viimpagados    NUMBER;
      vanulados      NUMBER;
      vianulados     NUMBER;
      vcestado       VARCHAR2(400);
      v_max_reg      parinstalacion.nvalpar%TYPE;
      vcont          NUMBER;
      vmsg           VARCHAR2(500);   -- Mostrar mensaje en pantalla si está limitado
   BEGIN
      v_max_reg := f_parinstalacion_n('N_MAX_REG');   -- Mostrar mensaje en pantalla si está limitado

      --CONTROL DE PARAMETROS DE ENTRADA
      --Comprovació de paràmetres d'entrada
      IF psproces IS NULL
         AND pfinirem IS NULL
         AND pffinrem IS NULL THEN
         vparam := 'Parámetros 1';
         RAISE e_error_controlat;
      END IF;

      vnumerr := pac_domiciliaciones.f_get_domiciliacion_cab(pcempres, psproces, pccobban,
                                                             pac_md_common.f_get_cxtidioma,
                                                             pfinirem, pffinrem, vsquery_total);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      vrefcursor := pac_md_listvalores.f_opencursor(vsquery_total, mensajes);

      IF vrefcursor IS NOT NULL THEN
         LOOP
            FETCH vrefcursor
             INTO vcempres, vsproces, vccobban, vfcreacion, vtfileenv, vtfiledev, vcremban,
                  vcusumod, vfusumod, vsdevolu, vremesados, viremesados, vcobrados,
                  vicobrados, vanulados, vianulados, vimpagados, viimpagados, vcestado,
                  vcestdom, vtcompany, vfdebito, vtcobban;

            vcont := vcont + 1;
            EXIT WHEN vrefcursor%NOTFOUND;
         END LOOP;

         --Si el cursor no te dades
         IF vcempres IS NULL THEN
            IF vrefcursor%ISOPEN THEN
               CLOSE vrefcursor;
            END IF;

            IF psproces IS NULL THEN
               pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes, 2, 0,
                                              f_axis_literales(9001249,
                                                               pac_iax_common.f_get_cxtidioma));   --No hi han rebuts pendents de domiciliar
            ELSE
               pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes, 2, 0,
                                              f_axis_literales(103778,
                                                               pac_iax_common.f_get_cxtidioma));   --Procés inexitent
            END IF;
         END IF;

         -- Mostrar mensaje en pantalla si está limitado
         IF vcont >(v_max_reg + 1) THEN
            vmsg := f_axis_literales(9901234, pac_iax_common.f_get_cxtidioma);
            vmsg := REPLACE(vmsg, '{0}', v_max_reg);
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 0, vmsg);
         END IF;

         --INICIALIZAR DE NUEVO
         vrefcursor := pac_md_listvalores.f_opencursor(vsquery_total, mensajes);
         RETURN vrefcursor;
      ELSE
         RETURN NULL;
      END IF;
   EXCEPTION
      WHEN e_error_controlat THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         IF vparam = 'Parámetro - Cobban' THEN
            -- Falta informar el cobrador bancario
            pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes, 1, 0,
                                              f_axis_literales(120081,
                                                               pac_iax_common.f_get_cxtidioma));
         -- fin Bug 21116 - APD - 09/02/2012
         ELSE
            -- Camps Proceso domiciliación o la Fecha efecto han de estar informados
            pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes, 1, 0,
                                              f_axis_literales(9903973,
                                                               pac_iax_common.f_get_cxtidioma));
         END IF;

         RETURN vrefcursor;
      WHEN e_param_error THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN vrefcursor;
      WHEN e_object_error THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;   --vrefcursor;
      WHEN OTHERS THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_domiciliacion_cab;

/*************************************************************************
 --6. 0021718: MDP_A001-Domiciliaciones: modificaciones generales - 0111176

       Funcion para modificar el cabecera de domiciliaciones
       param in pcempres   : Código de empresa
       param in psproces   : Código de proceso (número de remesa)
       param in pccobban   : Código de cobrador bancario
       param in pfefecto   : Fecha de efecto de la remesa
       param in ptfileenv  : Nombre del fichero de envío
       param in ptfiledev  : Nombre del fichero de devolución
       param in pcestdom   : Estado de la remesa
       param in pcremban   : Número de remesa interna de la entidad bancaria
       param in pidioma    : Código de idioma
       param out psquery   : Query
       return           : 0 indica cambio realizado correctamente
                          <> 0 indica error
*************************************************************************/
   FUNCTION f_set_domiciliacion_cab(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pccobban IN NUMBER,
      pfefecto IN DATE,
      ptfileenv IN VARCHAR2,
      ptfiledev IN VARCHAR2,
      pcestdom IN NUMBER,
      pcremban IN VARCHAR2,
      psdevolu IN NUMBER,
      psprocie IN NUMBER,   -- 9. 0022753: MDP_A001-Cierre de remesa (+)
      pcidioma IN NUMBER DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_md_domiciliaciones.f_set_domiciliacion_cab';
      vnumerr        NUMBER(8) := 0;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(2000)
         := 'parámetros - psproces: ' || psproces || ', pccobban: ' || pccobban
            || ', pcempres: ' || pcempres || ', pfefecto: ' || pfefecto || ', ptfileenv: '
            || ptfileenv || ', ptfiledev: ' || ptfiledev || ', pcestdom: ' || pcestdom
            || ', pcidioma: ' || pcidioma;
      v_object       VARCHAR2(200) := 'PAC_MD_ADM.f_set_imprecibo';
   BEGIN
      v_pasexec := 1;

      IF psproces IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_pasexec := 2;
      vnumerr :=
         pac_domiciliaciones.f_set_domiciliacion_cab
                                         (pcempres, psproces, pccobban, pfefecto, ptfileenv,
                                          ptfiledev, pcestdom, pcremban, psdevolu, psprocie,   -- 9. 0022753: MDP_A001-Cierre de remesa (+)
                                          pcidioma);

      IF vnumerr = 0 THEN
         v_pasexec := 3;
         --Se han actualizado correctamente los datos de la remesa bancaria.
         --pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9903625); -- 9. 0021718 - 0111176 (-)
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9903625);   -- 9. 0021718 - 0111176 (+)
      ELSE
         v_pasexec := 4;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      v_pasexec := 5;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_domiciliacion_cab;

/*************************************************************************
 --6. 0021718: MDP_A001-Domiciliaciones: modificaciones generales - 0111176

       Funcion para retroceder una domiciliación
       param in pcempres   : Código de empresa
       param in psproces   : Código de proceso (número de remesa)
       param in pfecha     : Fecha de la retrocesión
       param in pidioma    : Código de idioma
       return              : 0 indica cambio realizado correctamente
                          <> 0 indica error
*************************************************************************/
   FUNCTION f_retro_domiciliacion(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pfecha IN DATE,
      pcidioma IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_md_domiciliaciones.f_retro_domiciliacion';
      vnumerr        NUMBER(8) := 0;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(2000)
         := 'parámetros - psproces: ' || psproces || ', pcempres: ' || pcempres
            || ', pfecha: ' || pfecha || ', pcidioma: ' || pcidioma;
      v_object       VARCHAR2(200) := 'PAC_MD_ADM.f_set_imprecibo';
   BEGIN
      v_pasexec := 1;

      IF psproces IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_pasexec := 2;
      vnumerr := pac_domiciliaciones.f_retro_domiciliacion(pcempres, psproces, pfecha,
                                                           pcidioma);

      IF vnumerr = 0 THEN
         v_pasexec := 3;
         --Se ha retrocedido correctamente la remesa bancaria.
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9903626);
      ELSE
         v_pasexec := 4;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      v_pasexec := 5;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_retro_domiciliacion;
END pac_md_domiciliaciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_DOMICILIACIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_DOMICILIACIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_DOMICILIACIONES" TO "PROGRAMADORESCSI";
