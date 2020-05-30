--------------------------------------------------------
--  DDL for Package Body PAC_MD_COMISIONEGOCIO
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY PAC_MD_COMISIONEGOCIO AS
   /******************************************************************************
     NOMBRE:     pac_md_comisionegocio
     PROP¿SITO:  Package para gestionar los convenios de comisi¿n especial

     REVISIONES:
     Ver        Fecha        Autor             Descripci¿n
     ---------  ----------  ---------------  ------------------------------------
     1.0        19/12/2012   FAL             0025214: LCOL_C004-LCOL: Realizar desarrollo Comisiones Especiales negocio
     2.0       08/09/2019   ECP              2  IAXIS-4082. Convenio RC 
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
      Recupera la lista de los convenios de comisi¿n especial en funci¿n de los par¿metros recibidos
      param in pccodconv : identificador del convenio
      param in ptdesconv : descripci¿n del convenio
      param in pfinivig  : fecha de inicio de vigencia del convenio
      param in pffinvig  : fecha de fin de vigencia del convenio
      param in psproduc  : c¿digo de producto
      param in pcagente  : c¿digo de agente
      param in ptnomtom  : nombre de tomador
      param in pcramo    : c¿digo de ramo
      param out mensajes : colecci¿n mensajes error
      return             : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_lstconvcomesp(
      pccodconv IN NUMBER,
      ptdesconv IN VARCHAR2,
      pfinivig IN DATE,
      pffinvig IN DATE,
      psproduc IN NUMBER,
      pcagente IN NUMBER,
      ptnomtom IN VARCHAR2,
      pcramo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_md_comisionegocio.f_get_lstconvcomesp';
      vpar           VARCHAR2(500)
         := 'c=' || pccodconv || ' t=' || ptdesconv || ' i=' || pfinivig || ' f=' || pffinvig
            || ' p=' || psproduc || ' a=' || pcagente || ' n=' || ptnomtom || ' ramo='
            || pcramo;
      vsquery        VARCHAR2(2000);
      cur            sys_refcursor;
   BEGIN
      vpas := 1;
      --RCL 25/06/2013 - BUG 27327 - Permitimos buscar por RAMO
      vsquery := pac_comisionegocio.f_get_lstconvcomesp(pccodconv, ptdesconv, pfinivig,
                                                        pffinvig, psproduc, pcagente,
                                                        ptnomtom, pcramo);

      IF vsquery IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001846);
         RAISE e_object_error;
      END IF;

      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_get_lstconvcomesp;

   /*************************************************************************
      Recupera los datos del convenio de comisin especial
      param in pccodconv : identificador del convenio
      param out mensajes : coleccin mensajes error
      return             : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_datconvcomesp(pccodconv IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_convcomesp IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_md_comisionegocio.f_get_datconvcomesp';
      vpar           VARCHAR2(500) := 'i=' || pccodconv;
      convenio       ob_iax_convcomesp;
   BEGIN
      vpas := 1;

      IF pccodconv IS NULL THEN
         RAISE e_param_error;
      END IF;

      convenio := ob_iax_convcomesp();

      SELECT DISTINCT idconvcomesp, tdesconv, finivig,
                      ffinvig, cusualt
                 INTO convenio.idconvcomesp, convenio.tdesconv, convenio.finivig,
                      convenio.ffinvig, convenio.cusualt
                 FROM convcomisesp c
                WHERE c.idconvcomesp = pccodconv;

      BEGIN
         SELECT c.cagente, f_nombre(b.sperson, 3) tnomage
           INTO convenio.cagente, convenio.tnomage
           FROM convcomespage c, agentes b
          WHERE c.idconvcomesp = pccodconv
            AND b.cagente = c.cagente;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END;

      --INI IAX 4081 AABG: Se almacena la informacion en el ob_iax  
      convenio.asegurados := t_iax_personas();
      FOR cur IN(SELECT c.sperson, p.nnumide, f_nombre(c.sperson, 3) tnomtom                   
                   FROM convcomesptom c, per_personas p
                  WHERE c.idconvcomesp = pccodconv
                    AND c.sperson = p.sperson)
      LOOP
         convenio.asegurados.EXTEND;
         convenio.asegurados(convenio.asegurados.LAST) := ob_iax_personas();
         convenio.asegurados(convenio.asegurados.LAST).sperson := cur.sperson;
         convenio.asegurados(convenio.asegurados.LAST).nnumide := cur.nnumide;
         convenio.asegurados(convenio.asegurados.LAST).tnombre := cur.tnomtom;
      END LOOP;
      --FIN IAX 4081 AABG: Se almacena la informacion en el ob_iax

      convenio.comisiones := t_iax_gstcomision();
--Ini IAXIS-4082- 08/09/2019
      FOR cur IN (SELECT cmodcom, pcomisi, tatribu
                    FROM convcomisesp c, detvalores d
                   WHERE c.idconvcomesp(+) = pccodconv
                     AND c.cmodcom(+) = d.catribu
                     AND d.cvalor = 67
                     AND d.cidioma = pac_md_common.f_get_cxtidioma() and cmodcom = 1) 
                     --Ini IAXIS-4082- 08/09/2019
                     LOOP
         convenio.comisiones.EXTEND;
         convenio.comisiones(convenio.comisiones.LAST) := ob_iax_gstcomision();
         convenio.comisiones(convenio.comisiones.LAST).cmodcom := cur.cmodcom;
         convenio.comisiones(convenio.comisiones.LAST).pcomisi := cur.pcomisi;
         convenio.comisiones(convenio.comisiones.LAST).tatribu := cur.tatribu;
      END LOOP;

      convenio.productos := t_iax_info();

      FOR cur IN (SELECT c.sproduc, a.ttitulo tproduc
                    FROM convcomespprod c, productos b, titulopro a
                   WHERE c.idconvcomesp = pccodconv
                     AND b.sproduc = c.sproduc
                     AND a.cramo = b.cramo
                     AND a.cmodali = b.cmodali
                     AND a.ctipseg = b.ctipseg
                     AND a.ccolect = b.ccolect
                     AND a.cidioma = pac_md_common.f_get_cxtidioma()) LOOP
         convenio.productos.EXTEND;
         convenio.productos(convenio.productos.LAST) := ob_iax_info();
         convenio.productos(convenio.productos.LAST).nombre_columna := cur.sproduc;
         convenio.productos(convenio.productos.LAST).valor_columna := cur.tproduc;
      END LOOP;

      RETURN convenio;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_datconvcomesp;

   /*************************************************************************
      Recupera los datos del producto del convenio de comisi¿n especial
      param in pccodconv : identificador del convenio
      param out mensajes : colecci¿n mensajes error
      return             : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_prodconvcomesp(pccodconv IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_md_comisionegocio.f_get_prodconvcomesp';
      vpar           VARCHAR2(500) := 'i=' || pccodconv;
      vsquery        VARCHAR2(2000);
      cur            sys_refcursor;
   BEGIN
      vpas := 1;
      vsquery := pac_comisionegocio.f_get_prodconvcomesp(pccodconv);

      IF vsquery IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001846);
         RAISE e_object_error;
      END IF;

      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_get_prodconvcomesp;

   /*************************************************************************
      Recupera los datos del agente del convenio de comisi¿n especial
      param in pccodconv : identificador del convenio
      param out mensajes : colecci¿n mensajes error
      return             : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_ageconvcomesp(pccodconv IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_md_comisionegocio.f_get_ageconvcomesp';
      vpar           VARCHAR2(500) := 'i=' || pccodconv;
      vsquery        VARCHAR2(2000);
      cur            sys_refcursor;
   BEGIN
      vpas := 1;
      vsquery := pac_comisionegocio.f_get_ageconvcomesp(pccodconv);

      IF vsquery IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001846);
         RAISE e_object_error;
      END IF;

      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_get_ageconvcomesp;

   /*************************************************************************
      Recupera los datos del tomador del convenio de comisi¿n especial
      param in pccodconv : identificador del convenio
      param out mensajes : colecci¿n mensajes error
      return             : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_tomconvcomesp(pccodconv IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_md_comisionegocio.f_get_tomconvcomesp';
      vpar           VARCHAR2(500) := 'i=' || pccodconv;
      vsquery        VARCHAR2(2000);
      cur            sys_refcursor;
   BEGIN
      vpas := 1;
      vsquery := pac_comisionegocio.f_get_tomconvcomesp(pccodconv);

      IF vsquery IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001846);
         RAISE e_object_error;
      END IF;

      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_get_tomconvcomesp;

   /*************************************************************************
      Borra los el agente de un convenio de comisi¿n especial
      param in pccodconv : identificador del convenio
      param in pcagente  : c¿digo de agente
      param out mensajes : colecci¿n mensajes error
      return             : 0 si est¿ todo Ok y 1 si existe alg¿n tipo de error
   *************************************************************************/
   FUNCTION f_del_ageconvcomesp(
      pccodconv IN NUMBER,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_md_comisionegocio.f_del_ageconvcomesp';
      vpar           VARCHAR2(500) := 'i=' || pccodconv || ' a=' || pcagente;
      num_err        NUMBER;
   BEGIN
      vpas := 100;
      num_err := pac_comisionegocio.f_del_ageconvcomesp(pccodconv, pcagente);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      RETURN 0;
      RETURN num_err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_ageconvcomesp;

   /*************************************************************************
      Borra el tomador de un convenio de comisi¿n especial
      param in pccodconv : identificador del convenio
      param in psperson  : c¿digo del tomador
      param out mensajes : colecci¿n mensajes error
      return             : 0 si est¿ todo Ok y 1 si existe alg¿n tipo de error
   *************************************************************************/
   FUNCTION f_del_tomconvcomesp(
      pccodconv IN NUMBER,
      psperson IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_md_comisionegocio.f_del_tomconvcomesp';
      vpar           VARCHAR2(500) := 'i=' || pccodconv || ' p=' || psperson;
      num_err        NUMBER;
   BEGIN
      vpas := 100;
      num_err := pac_comisionegocio.f_del_tomconvcomesp(pccodconv, psperson);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      RETURN 0;
      RETURN num_err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_tomconvcomesp;

   /*************************************************************************
      Actualiza/inserta los datos de un convenio de comisin especial
      param in pccodconv : identificador del convenio
      param in ptdesconv : descripcin del convenio
      param in pfinivig  : fecha de inicio de vigencia del convenio
      param in pffinvig  : fecha de fin de vigencia del convenio
      param in plistaprods : coleccin de productos que intervienen en el convenio
      param in plistacomis : coleccin de comisiones que intervienen en el convenio (segn cmodcom con su %)
      param in pcagente  : % de comisin especial del convenio
      param in psperson  : sperson del tomador que interviene en el convenio
      param in pprimausd  : prima en USD
      param in pprimaeur  : prima en EUR
      param out pccodconv_out  : identificador del nuevo convenio creado
      param out mensajes : coleccin mensajes error
      return             : 0 si est todo Ok y 1 si existe algn tipo de error
   *************************************************************************/
   --INI IAXIS 4081 AABG: Se realiza insercion en nueva tabla y con los nuevos parametros
   FUNCTION f_set_datconvcomesp(
      pccodconv IN NUMBER,
      ptdesconv IN VARCHAR2,
      pfinivig IN DATE,
      pffinvig IN DATE,
      plistaprods IN t_iax_info,
      plistacomis IN t_iax_info,
      pcagente IN NUMBER,
      psperson IN VARCHAR2,
      pnnumide IN VARCHAR2,
      ptasa IN  NUMBER,
      pprima IN NUMBER,
      pprimausd IN NUMBER,
      pprimaeur IN NUMBER,
      pccodconv_out IN OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_md_comisionegocio.f_set_datconvcomesp';
      vpar           VARCHAR2(500)
         := ' c=' || pccodconv || ' t=' || ptdesconv || ' i=' || pfinivig || ' f=' || pffinvig
            || ' age=' || pcagente || ' tom=' || psperson || ' io=' || pccodconv_out;
      num_err        NUMBER;
      v_idconv       NUMBER;
      vcountcomi     NUMBER;
      v_value        VARCHAR2(40);
      v_valorcol     VARCHAR2(10);
      
      --INI IAXIS 4081 AABG: Variables para el manejo de tasa y prima
      v_codgaran        VARCHAR2(40);
      v_tasagaran     VARCHAR2(100);
      --v_tasa    NUMBER;
      --v_prima    NUMBER;
      v_prodsel    NUMBER;
      --INI IAXIS 4081 AABG: Variables para el manejo de tasa y prima
      
      --INI IAXIS 4081 AABG: Se crea cursor para recorrer los sproduct separados por ;
      CURSOR cur_asegurados
          IS
            WITH  
             tab1 AS  
             (  
               SELECT   
                 regexp_substr(psperson,'[^;]+',1,LEVEL) sperson,
                 regexp_substr(pnnumide,'[^;]+',1,LEVEL) nnumide 
               FROM dual   
               CONNECT BY regexp_substr(psperson,'[^;]+',1,LEVEL) IS NOT NULL
             )  
            SELECT  
              t.sperson, t.nnumide  
            FROM tab1 t;
            
        CURSOR cur_garan_info(info VARCHAR2)
            IS
             WITH
              tab2 AS
              (
                SELECT   
                     regexp_substr(info,'[^~]+',1,LEVEL) codgaran
                    FROM dual   
                    CONNECT BY regexp_substr(info,'[^~]+',1,LEVEL) IS NOT NULL
              )
           SELECT  
              t.codgaran
            FROM tab2 t;  
        r_infoGarantias  cur_garan_info%rowtype;
      --FIN IAXIS 4081 AABG: Se crea cursor para recorrer los sproduct separados por ;
   BEGIN
      vpas := 100;
      
      --FIN IAXIS 4081 AABG: Por cada asegurado se hace la validacion
      FOR c IN cur_asegurados
         LOOP
            -- Validacin datos convenio
             num_err := pac_comisionegocio.f_valida_creaconv(pccodconv, pfinivig, pffinvig,
                                                              plistaprods, pcagente, c.sperson, pprimausd, pprimaeur);
        
              IF num_err <> 0 THEN
                 RETURN num_err;
              --pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
              --RAISE e_object_error;
              END IF;
         END LOOP;
      --FIN IAXIS 4081 AABG: Por cada asegurado se hace la validacion  
      
      IF plistacomis IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9904685);
         RAISE e_object_error;   -- Es obligatorio definir una comisin especial para el convenio
      END IF;

      IF plistacomis.COUNT = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9904685);
         RAISE e_object_error;   -- Es obligatorio definir una comisin especial para el convenio
      END IF;

      IF pccodconv IS NULL THEN
         v_idconv := pac_comisionegocio.f_get_next_conv;
         pccodconv_out := v_idconv;
      ELSE
         v_idconv := pccodconv;
      END IF;

      vcountcomi := 0;

      FOR i IN plistacomis.FIRST .. plistacomis.LAST LOOP
         IF plistacomis(i).valor_columna IS NOT NULL THEN
            SELECT VALUE
              INTO v_value
              FROM nls_session_parameters
             WHERE parameter = 'NLS_NUMERIC_CHARACTERS';

            v_valorcol := plistacomis(i).valor_columna;

            IF v_value = '.,' THEN
               v_valorcol := REPLACE(v_valorcol, ',', '.');
            END IF;

            num_err :=
               pac_comisionegocio.f_set_datconvcomesp
                                                    (v_idconv, ptdesconv, pfinivig, pffinvig,
                                                     v_valorcol,   --plistacomis(i).valor_columna,
                                                     plistacomis(i).nombre_columna);

            IF num_err <> 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
               RAISE e_object_error;
            END IF;

            vcountcomi := vcountcomi + 1;
         END IF;
      END LOOP;

      IF vcountcomi = 0 THEN
         RETURN 9904685;   -- Es obligatorio definir una comisin especial para el convenio
      END IF;

      DELETE FROM convcomespprod
            WHERE idconvcomesp = v_idconv;

      DELETE FROM SGT_SUBTABS_DET
      WHERE CCLA5 = v_idconv;
      
      FOR j IN plistaprods.FIRST .. plistaprods.LAST LOOP
         IF plistaprods(j).seleccionado = 1 THEN
            IF plistaprods(j).nombre_columna = 'SPRODUC' THEN
                FOR c IN cur_asegurados
                 LOOP
                     num_err := pac_comisionegocio.f_set_prodconvcomesp(v_idconv,
                                                                  plistaprods(j).valor_columna);                
                      --INI IAXIS 4081 AABG: Se inserta en la tabal SGT
                      IF c.nnumide IS NOT NULL THEN
                        
                        --IF v_prodsel = plistaprods(j).valor_columna THEN
                        
                        --INI IAXIS 4081 AABG: SE RECORRE LAS GARANTIAS POR PRODUCTO
                            OPEN cur_garan_info(plistaprods(j).tipo_columna); 
                            LOOP                            
                                FETCH cur_garan_info INTO r_infoGarantias;
                                EXIT WHEN cur_garan_info%notfound;
                                
                                v_codgaran := '';
                                v_tasagaran := '';
                                SELECT SUBSTR(r_infoGarantias.codgaran,0,INSTR(r_infoGarantias.codgaran, '-')-1),
                                   SUBSTR(r_infoGarantias.codgaran,INSTR(r_infoGarantias.codgaran, '-')+1,LENGTH(r_infoGarantias.codgaran) - LENGTH(SUBSTR(r_infoGarantias.codgaran,0,INSTR(r_infoGarantias.codgaran, '-')+1)))
                                   INTO v_codgaran, v_tasagaran
                                 FROM DUAL; 
                                
                                num_err := pac_comisionegocio.f_set_subtabsdet(plistaprods(j).valor_columna, 
                                                                        c.nnumide,
                                                                        v_tasagaran,
                                                                        pprima,                                                                        
                                                                        v_idconv,
                                                                        v_codgaran);
                                 IF num_err <> 0 THEN
                                    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
                                    RAISE e_object_error;
                                 END IF;
                            END LOOP;    
                            CLOSE cur_garan_info;
                        --FIN IAXIS 4081 AABG: SE RECORRE LAS GARANTIAS POR PRODUCTO
                        
                      END IF;  
                      --FIN IAXIS 4081 AABG: Se inserta en la tabal SGT
                 END LOOP;                                                                  
            END IF;
         END IF;
      END LOOP;
      IF pcagente IS NOT NULL THEN
         num_err := pac_comisionegocio.f_set_ageconvcomesp(v_idconv, pcagente);

         IF num_err <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
            RAISE e_object_error;
         END IF;
      END IF;
    --INI IAXIS 4081 AABG: Se recorre las personas para insertar
    DELETE FROM convcomesptom WHERE idconvcomesp = v_idconv;
        FOR c IN cur_asegurados
         LOOP
              IF c.sperson IS NOT NULL THEN
                 num_err := pac_comisionegocio.f_set_tomconvcomesp(v_idconv, c.sperson);
            
                 IF num_err <> 0 THEN
                    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
                    RAISE e_object_error;
                 END IF;
              END IF; 
         END LOOP;   
         
     --INI IAXIS 4081 AABG: Se almacena la informacion de las primas del convenio
        num_err := pac_comisionegocio.f_set_convprima(v_idconv, pprima, pprimausd, pprimaeur);

         IF num_err <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
            RAISE e_object_error;
         END IF;
     --FIN IAXIS 4081 AABG: Se almacena la informacion de las primas del convenio    
         
      RETURN num_err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_datconvcomesp;
   --FIN IAXIS 4081 AABG: Se realiza insercion en nueva tabla y con los nuevos parametros

   /*************************************************************************
      Parametriza un producto como afectado por un convenio de comisi¿n especial
      param in pccodconv : identificador del convenio
      param in plistaprods  : colecci¿n de ids de producto
      param out mensajes : colecci¿n mensajes error
      return             : 0 si est¿ todo Ok y 1 si existe alg¿n tipo de error
   *************************************************************************/

   /*
      FUNCTION f_set_prodconvcomesp(
         pccodconv IN NUMBER,
         plistaprods IN t_iax_info,
         mensajes OUT t_iax_mensajes)
         RETURN NUMBER IS
         vpas           NUMBER;
         vobj           VARCHAR2(500) := 'pac_md_comisionegocio.f_set_prodconvcomesp';
         vpar           VARCHAR2(500) := 'i=' || pccodconv;
         num_err        NUMBER;
      BEGIN
         IF pccodconv IS NULL THEN
            RAISE e_param_error;
         END IF;

         IF plistaprods IS NULL THEN
            RETURN 0;
         END IF;

         IF plistaprods.COUNT = 0 THEN
            RETURN 0;
         END IF;

         FOR j IN plistaprods.FIRST .. plistaprods.LAST LOOP
            IF plistaprods(j).seleccionado = 1 THEN
               IF plistaprods(j).nombre_columna = 'sproduc' THEN
                  num_err := pac_comisionegocio.f_set_prodconvcomesp(pccodconv,
                                                                     plistaprods(j).valor_columna);
               END IF;
            ELSE
               IF plistaprods(j).nombre_columna = 'sproduc' THEN
                  DELETE FROM convcomespprod
                        WHERE idconvcomesp = pccodconv
                          AND sproduc = plistaprods(j).valor_columna;
               END IF;
            END IF;
         END LOOP;

         RETURN 0;
      EXCEPTION
         WHEN e_param_error THEN
            pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);
            RETURN 1;
         WHEN e_object_error THEN
            pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
            RETURN 1;
         WHEN OTHERS THEN
            pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                              psqcode => SQLCODE, psqerrm => SQLERRM);
            RETURN 1;
      END f_set_prodconvcomesp;
   */

   /*************************************************************************
      Parametriza un agente como afectado por un convenio de comisi¿n especial
      param in pccodconv : identificador del convenio
      param in pcagente  : c¿digo de agente
      param out mensajes : colecci¿n mensajes error
      return             : 0 si est¿ todo Ok y 1 si existe alg¿n tipo de error
   *************************************************************************/

   /*
      FUNCTION f_set_ageconvcomesp(
         pccodconv IN NUMBER,
         pcagente IN NUMBER,
         mensajes OUT t_iax_mensajes)
         RETURN NUMBER IS
         vpas           NUMBER;
         vobj           VARCHAR2(500) := 'pac_md_comisionegocio.f_set_ageconvcomesp';
         vpar           VARCHAR2(500) := 'i=' || pccodconv || ' a=' || pcagente;
         num_err        NUMBER;
      BEGIN
         vpas := 100;
         num_err := pac_comisionegocio.f_set_ageconvcomesp(pccodconv, pcagente);

         IF num_err <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
            RAISE e_object_error;
         END IF;

         RETURN 0;
         RETURN num_err;
      EXCEPTION
         WHEN e_param_error THEN
            pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
            RETURN 1;
         WHEN e_object_error THEN
            pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);
            RETURN 1;
         WHEN OTHERS THEN
            pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                              psqcode => SQLCODE, psqerrm => SQLERRM);
            RETURN 1;
      END f_set_ageconvcomesp;

   */

   /*************************************************************************
      Parametriza un tomador como afectado por un convenio de comisi¿n especial
      param in pccodconv : identificador del convenio
      param in psperson  : c¿digo del tomador
      param out mensajes : colecci¿n mensajes error
      return             : 0 si est¿ todo Ok y 1 si existe alg¿n tipo de error
   *************************************************************************/

   /*
      FUNCTION f_set_tomconvcomesp(
         pccodconv IN NUMBER,
         psperson IN NUMBER,
         mensajes OUT t_iax_mensajes)
         RETURN NUMBER IS
         vpas           NUMBER;
         vobj           VARCHAR2(500) := 'pac_md_comisionegocio.f_set_tomconvcomesp';
         vpar           VARCHAR2(500) := 'i=' || pccodconv || ' s=' || psperson;
         num_err        NUMBER;
      BEGIN
         vpas := 100;
         num_err := pac_comisionegocio.f_set_tomconvcomesp(pccodconv, psperson);

         IF num_err <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
            RAISE e_object_error;
         END IF;

         RETURN 0;
         RETURN num_err;
      EXCEPTION
         WHEN e_param_error THEN
            pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
            RETURN 1;
         WHEN e_object_error THEN
            pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);
            RETURN 1;
         WHEN OTHERS THEN
            pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                              psqcode => SQLCODE, psqerrm => SQLERRM);
            RETURN 1;
      END f_set_tomconvcomesp;
   */

   /*************************************************************************
      Recuperar el % de comisi¿n especial de un convenio
      param in psproduc : c¿digo del producto
      param in pcagente : c¿digo de agente
      param in psperson : c¿digo del tomador
      param in pfemisio : fecha emisi¿n de la p¿liza
      param out mensajes : colecci¿n mensajes error
      return            : t_iax_gstcomision
   *************************************************************************/
   FUNCTION f_get_porcenconvcomesp(
      psproduc IN NUMBER,
      pcagente IN NUMBER,
      psperson IN NUMBER,
      pfemisio IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_gstcomision IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_md_comisionegocio.f_get_porcenconvcomesp';
      vpar           VARCHAR2(500)
            := 's=' || psproduc || ' a=' || pcagente || ' p=' || psperson || ' f=' || pfemisio;
      num_err        NUMBER;
      v_idconvcomesp convcomisesp.idconvcomesp%TYPE;
      colcom         t_iax_gstcomision;
      v_existconvtom NUMBER := 0;
      v_spereal      estper_personas.spereal%TYPE;
   BEGIN
      IF psproduc IS NULL
         OR pfemisio IS NULL
         OR pcagente IS NULL THEN
         RAISE NO_DATA_FOUND;
      END IF;

      IF psperson IS NOT NULL THEN
         BEGIN
            SELECT spereal
              INTO v_spereal
              FROM estper_personas
             WHERE sperson = psperson;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_spereal := NULL;
         END;
      END IF;

      colcom := t_iax_gstcomision();

      BEGIN
         SELECT DISTINCT c.idconvcomesp
                    INTO v_idconvcomesp
                    FROM convcomisesp c, convcomesptom t, convcomespprod p, convcomespage a
                   WHERE c.finivig <= pfemisio
                     AND(c.ffinvig IS NULL
                         OR c.ffinvig >= pfemisio)
                     AND c.idconvcomesp = t.idconvcomesp
                     AND t.idconvcomesp = p.idconvcomesp
                     AND p.idconvcomesp = a.idconvcomesp
                     AND t.sperson = v_spereal
                     AND p.sproduc = psproduc
                     AND a.cagente = pcagente;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               SELECT DISTINCT c.idconvcomesp
                          INTO v_idconvcomesp
                          FROM convcomisesp c, convcomespprod p, convcomespage a
                         WHERE c.finivig <= pfemisio
                           AND(c.ffinvig IS NULL
                               OR c.ffinvig >= pfemisio)
                           AND p.idconvcomesp = a.idconvcomesp
                           AND c.idconvcomesp = a.idconvcomesp
                           AND p.sproduc = psproduc
                           AND a.cagente = pcagente
                           -- Bug 27327/148138 - 03/07/2013 - AMC
                           AND c.idconvcomesp NOT IN(SELECT idconvcomesp
                                                       FROM convcomesptom);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
               BEGIN
                   SELECT DISTINCT c.idconvcomesp
                    INTO v_idconvcomesp
                    FROM convcomisesp c, convcomesptom t, convcomespprod p, convcomespage a
                   WHERE c.finivig <= pfemisio
                     AND(c.ffinvig IS NULL
                         OR c.ffinvig >= pfemisio)
                     AND c.idconvcomesp = t.idconvcomesp
                     AND t.idconvcomesp = p.idconvcomesp
                     AND p.idconvcomesp = a.idconvcomesp
                     AND t.sperson = psperson
                     AND p.sproduc = psproduc
                     AND a.cagente = pcagente;
               EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_idconvcomesp := NULL;
               END;
            END;
      END;

      IF v_idconvcomesp IS NOT NULL THEN
         v_existconvtom := 0;

         SELECT COUNT(1)
           INTO v_existconvtom
           FROM convcomesptom
          WHERE idconvcomesp = v_idconvcomesp;

         IF v_existconvtom > 0 THEN
            BEGIN
               SELECT 1
                 INTO v_existconvtom
                 FROM convcomesptom
                WHERE idconvcomesp = v_idconvcomesp
                  AND sperson = v_spereal;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
               BEGIN
                 SELECT 1
                 INTO v_existconvtom
                 FROM convcomesptom
                WHERE idconvcomesp = v_idconvcomesp
                  AND sperson = psperson;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_idconvcomesp := NULL;
               END;
            END;
         END IF;
      END IF;
-- Ini 4082 -- ECP -- 08/09/2019
      IF v_idconvcomesp IS NOT NULL THEN
         FOR reg IN (SELECT cmodcom, pcomisi
                       FROM convcomisesp
                      WHERE idconvcomesp = v_idconvcomesp and cmodcom = 1) LOOP
                      
                      -- Fin 4082 -- ECP -- 08/09/2019
            colcom.EXTEND;
            colcom(colcom.LAST) := ob_iax_gstcomision();
            colcom(colcom.LAST).cmodcom := reg.cmodcom;
            colcom(colcom.LAST).pcomisi := reg.pcomisi;

            SELECT tatribu
              INTO colcom(colcom.LAST).tatribu
              FROM detvalores
             WHERE cvalor = 67
               AND cidioma = pac_md_common.f_get_cxtidioma()
               AND catribu = reg.cmodcom;

            IF reg.cmodcom IN(1, 3) THEN
               colcom(colcom.LAST).ninialt := 1;
               colcom(colcom.LAST).nfinalt := 1;
            ELSIF reg.cmodcom IN(2, 4) THEN
               colcom(colcom.LAST).ninialt := 2;
               colcom(colcom.LAST).nfinalt := 99;
            END IF;
         --colcom(colcom.LAST).ctipoesp := 2;
         END LOOP;
      ELSE   -- no exuiste convenio de comision especial
         --pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         -- RAISE e_object_error;
         RETURN NULL;
      END IF;

      RETURN colcom;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_porcenconvcomesp;

   /*************************************************************************
      Recuperar el siguiene c¿digo de convenio

      return  : id del convenio
   *************************************************************************/
   FUNCTION f_get_next_conv(pccodconv_out OUT NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_md_comisionegocio.f_get_next_conv';
      vpar           VARCHAR2(500);
   BEGIN
      pccodconv_out := pac_comisionegocio.f_get_next_conv;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_next_conv;

   /*************************************************************************
      Nos devuelve si un tomador o agente tiene parametrizado un convenio
      param in pspersonton : identificador del tomador
      param in pcagente    : identificador del agente
      param out pconvenio  : 0 - no tiene conveno parametrizado 1 - Si
      return             : Codigo de error

      Bug 27327/146916 - 27/06/2013 - AMC
   *************************************************************************/
   FUNCTION f_get_tieneconvcomesp(
      pspersonton IN NUMBER,
      pcagente IN NUMBER,
      psproduc IN NUMBER,
      pfefecto IN DATE,
      pconvenio OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_md_comisionegocio.f_get_tieneconvcomesp';
      vpar           VARCHAR2(500)
                                  := 'pspersonton=' || pspersonton || ' pcagente=' || pcagente;
      num_err        NUMBER;
   BEGIN
      IF pspersonton IS NULL
         AND pcagente IS NULL THEN
         RAISE e_param_error;
      END IF;

      num_err := pac_comisionegocio.f_get_tieneconvcomesp(pspersonton, pcagente, psproduc,
                                                          pfefecto, pconvenio);

      IF num_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_tieneconvcomesp;
   
 /*************************************************************************
      Obtiene la tasa o prima de un producto para un asegurado
      param in pccodconv : identificador del convenio
      param in pcnnumide  : numero identificacion asegurado
      param in pccodproducto : identificador del producto
      param in pcopcion  : opcion a consultar (1-> Tasa, 2-> Prima)
      return             : 0 si está todo Ok y 1 si existe algún tipo de error
   *************************************************************************/
   FUNCTION f_get_tasa_prima(
      pccodconv IN NUMBER, 
      pcnnumide IN NUMBER, 
      pccodproducto IN NUMBER, 
      pcopcion IN NUMBER,
      pccodgarantia IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_md_comisionegocio.f_get_tasa_prima';
      vpar           VARCHAR2(500) := 'i=' || pccodconv || ' a=' || pcnnumide || 'c=' || pccodproducto || ' d=' || pcopcion;
      num_err        NUMBER;
   BEGIN
      vpas := 100;
      num_err := pac_comisionegocio.f_get_tasa_prima(pccodconv, pcnnumide, pccodproducto, pcopcion, pccodgarantia);

      IF num_err = -1 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      RETURN num_err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
         RETURN -1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);
         RETURN -1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN -1;
   END f_get_tasa_prima;   
   
END pac_md_comisionegocio;

/