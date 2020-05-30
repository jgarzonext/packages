--------------------------------------------------------
--  DDL for Package Body PAC_IAX_PRODUCCION_AUT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_PRODUCCION_AUT" IS
/******************************************************************************
   NOMBRE:       PAC_IAX_PRODUCCION_AUT
   PROPÓSITO: Funcions per gestionar autos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        03/03/2009   XVM                1. Creación del package.
   2.0        04/10/2010   JTS                2. 16163: CRT - Modificar tabla descripcion riesgo (autriesgo)
   3.0        13/02/2013   JDS                3. 0025859: LCOL_T031-LCOL - AUT - Pantalla conductores (axisctr061) Id 428
   4.0        14/02/2013   JDS                4. 0025964: LCOL - AUT - Experiencia
   4.0        29/04/2013   JDS                4. 0025964: LCOL - AUT - Experiencia
   5.0        25/06/2013   RCL                5. 0024697: Canvi mida camp sseguro
   6.0        22/08/2013   JSV                6  0027953: LCOL - Autos Garantias por Modalidad
   7.0        13/09/2013   JDS                7  0027923: LCOL_F3BTEC-MTF3B - LCOL_TEC23 - Definicion de condiciones en Certificado 0
   8.0        16/10/2013   SHA                8  00026923: LCOL - TEC - Revisión Q-Trackers Fase 3A
   9.0        18/12/2013   JDS                9. 0026923: LCOL - TEC - Revisión Q-Trackers Fase 3A
   10.0       14/01/2014   JDS                10. 0029659: LCOL_T031-Migración autos
   11.0       06/01/2015   HRE                11. 33752_0195193: QT-0015045: Se modifica la consulta en la funcionn f_set_dispositivonoserie para que
                                                                 realice la busqueda de la descripcion del dispositivo tambien para la version 1.

******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
      FUNCTION f_lee_riesauto
         Funció que retorna un auto per un risc en concret
         param in  pnriesgo : número risc
         param out pcacc    : codi accesori
         param out mensajes : col·lecció de missatges
         return             : objecte d'autos (ob_iax_autriesgo)
   *************************************************************************/
   FUNCTION f_lee_riesauto(pnriesgo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN ob_iax_autriesgos IS
      vobauto        ob_iax_autriesgos := ob_iax_autriesgos();
      vobdetpoliza   ob_iax_detpoliza;
      vobriesgos     ob_iax_riesgos;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000) := 'parámetros - pnriesgo: ' || pnriesgo;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRODUCCION_AUT.f_lee_riesauto';
      num_err        NUMBER;
   BEGIN
      vobdetpoliza := pac_iobj_prod.f_getpoliza(mensajes);

      IF mensajes IS NOT NULL THEN
         vpasexec := 2;
         RAISE e_object_error;
      END IF;

      vobriesgos := pac_iobj_prod.f_partpolriesgo(vobdetpoliza, pnriesgo, mensajes);

      IF mensajes IS NOT NULL THEN
         vpasexec := 2;
         RAISE e_object_error;
      END IF;

      vpasexec := 3;
      vobauto := pac_iobj_prod.f_partriesautomoviles(vobriesgos, mensajes);

      IF mensajes IS NOT NULL THEN
         vpasexec := 4;
         RAISE e_object_error;
      END IF;

      RETURN vobauto;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_lee_riesauto;

   /*************************************************************************
      FUNCTION f_lee_conductor
         Funció que retorna un conductor per un risc i ordre en concret
         param in  pnriesgo : número risc
         param out mensajes : col·lecció de missatges
         param in  pnorden  : número ordre (default 1)
         return             : objecte conductor (ob_iax_autconductores)
   *************************************************************************/
   FUNCTION f_lee_conductor(
      pnriesgo IN NUMBER,
      mensajes OUT t_iax_mensajes,
      pnorden IN NUMBER DEFAULT 1)
      RETURN ob_iax_autconductores IS
      vobdetpoliza   ob_iax_detpoliza;
      vobauto        ob_iax_autriesgos;
      vobconduc      ob_iax_autconductores;
      vtobconduc     t_iax_autconductores;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
                         := 'parámetros - pnriesgo: ' || pnriesgo || ' - pnorden: ' || pnorden;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRODUCCION_AUT.f_lee_conductor';
   BEGIN
      IF pnriesgo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vobdetpoliza := pac_iobj_prod.f_getpoliza(mensajes);

      IF mensajes IS NOT NULL THEN
         vpasexec := 2;
         RAISE e_object_error;
      END IF;

      vobauto := pac_iobj_prod.f_partriesautomovil(vobdetpoliza, pnriesgo, mensajes);

      IF mensajes IS NOT NULL THEN
         vpasexec := 3;
         RAISE e_object_error;
      END IF;

      vtobconduc := pac_iobj_prod.f_partautconductores(vobauto, mensajes);

      IF mensajes IS NOT NULL THEN
         vpasexec := 4;
         RAISE e_object_error;
      END IF;

      FOR reg IN vtobconduc.FIRST .. vtobconduc.LAST LOOP
         IF vtobconduc.EXISTS(reg) THEN
            vpasexec := 5;

            IF vtobconduc(reg).norden = pnorden THEN
               vpasexec := 6;
               RETURN vtobconduc(reg);
            END IF;
         END IF;
      END LOOP;

      vpasexec := 7;
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 999999,
                                           'No se ha encontrado el conductor');
      RETURN NULL;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_lee_conductor;

   /*************************************************************************
      FUNCTION f_lee_conductores
         Funció que retorna la col·lecció de conductors per un risc en concret
         param in  pnriesgo : número risc
         param out mensajes : col·lecció de missatges
         return             : colecció de conductors (t_iax_autconductores)
   *************************************************************************/
   FUNCTION f_lee_conductores(pnriesgo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iax_autconductores IS
      vobdetpoliza   ob_iax_detpoliza;
      vobauto        ob_iax_autriesgos;
      vtobconduc     t_iax_autconductores;
      vobpersona     ob_iax_personas;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000) := 'parámetros - pnriesgo: ' || pnriesgo;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRODUCCION_AUT.f_lee_conductores';
      vnriesgo       NUMBER;
   BEGIN
      IF pnriesgo IS NULL THEN
         vnriesgo := 1;   -- Si es nulo, por defecto le pasamos un 1.
      ELSE
         vnriesgo := pnriesgo;
      END IF;

      vobdetpoliza := pac_iobj_prod.f_getpoliza(mensajes);

      IF mensajes IS NOT NULL THEN
         vpasexec := 2;
         RAISE e_object_error;
      END IF;

      vobauto := pac_iobj_prod.f_partriesautomovil(vobdetpoliza, vnriesgo, mensajes);

      IF mensajes IS NOT NULL THEN
         vpasexec := 3;
         RAISE e_object_error;
      END IF;

      vtobconduc := pac_iobj_prod.f_partautconductores(vobauto, mensajes);

      IF mensajes IS NOT NULL THEN
         vpasexec := 4;
         RAISE e_object_error;
      END IF;

      IF vtobconduc.COUNT > 0 THEN
         FOR vcon IN vtobconduc.FIRST .. vtobconduc.LAST LOOP
            IF vtobconduc.EXISTS(vcon) THEN
               IF vtobconduc(vcon) IS NOT NULL THEN   -- Se obtiene los datos de la persona
                  vobpersona := pac_md_persona.f_get_persona(vtobconduc(vcon).sperson, NULL,
                                                             mensajes, 'EST');

                  IF vobpersona IS NULL THEN
                     RAISE e_object_error;
                  END IF;

                  vtobconduc(vcon).persona := vobpersona;
               END IF;
            END IF;
         END LOOP;
      END IF;

      RETURN vtobconduc;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_lee_conductores;

   /*************************************************************************
      FUNCTION f_exist_propietarioconductor
         Funció que valida si la persona passada per paràmetre es el conductor principal
         param in  pnriesgo : número risc
         param out mensajes : col·lecció de missatges
         param in  pnorden  : número ordre (default 1)
         return             : 0 -> Persona NO conductor principal
                              1 -> Persona conductor principal
   *************************************************************************/
   FUNCTION f_exist_propietarioconductor(
      pnriesgo IN NUMBER,
      mensajes OUT t_iax_mensajes,
      pnorden IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      vobdetpoliza   ob_iax_detpoliza;
      vobauto        ob_iax_autriesgos;
      vobconduc      ob_iax_autconductores;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
                          := 'parámetros - pnriesgo: ' || pnriesgo || ' - pnorden:' || pnorden;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRODUCCION_AUT.f_exist_propietarioconductor';
   BEGIN
      IF pnriesgo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vobconduc := f_lee_conductor(pnriesgo, mensajes, pnorden);

      IF mensajes IS NOT NULL THEN
         vpasexec := 2;
         RAISE e_object_error;
      END IF;

      IF asegurado IS NULL
         OR vobconduc IS NULL THEN
         RETURN 0;   --Si no trobrem res retornen que no es conductor principal
      ELSE
         IF asegurado.sperson = vobconduc.sperson THEN
            RETURN 1;
         ELSE
            RETURN 0;
         END IF;
      END IF;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 0;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 0;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 0;
   END f_exist_propietarioconductor;

-- Bug 9247 - APD - 06/03/2009 -- Se crea la funcion f_set_detautriesgos
   /*************************************************************************
      FUNCTION f_set_detautriesgos
         Función que insertará en objeto ob_iax_autaccesorios del objeto póliza
         param in pnriesgo: numero de riesgo
         param in pnmovimi: numero de movimiento
         param in pcversion: codigo de version
         param in pcaccesorio: codigo del accesorio
         param in pctipacc: codigo del tipo de accesorio
         param in pfini: fecha de inicio o alta
         param in pivalacc: valor del accesorio
         param in ptdesacc: descripcion del accesorio
         param out mensajes : col·lecció de missatges
         return             : 0 -> Si todo OK
                              1 -> Si ha habido un error
   *************************************************************************/
   FUNCTION f_set_detautriesgos(
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcversion IN VARCHAR2,
      pcaccesorio IN VARCHAR2,
      pctipacc IN VARCHAR2,
      pfini IN DATE,
      pivalacc IN NUMBER,
      ptdesacc IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'parámetros - pnriesgo: ' || pnriesgo || ' pnmovimi:' || pnmovimi || ' pcversion:'
            || pcversion || ' pcaccesorio:' || pcaccesorio || ' pctipacc:' || pctipacc
            || ' pfini:' || pfini || ' pivalacc:' || pivalacc || ' ptdesacc:' || ptdesacc;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRODUCCION_AUT.f_set_detautriesgos';
      num_err        NUMBER;
   BEGIN
      num_err := pac_md_produccion_aut.f_set_detautriesgos(pnriesgo, pnmovimi, pcversion,
                                                           pcaccesorio, pctipacc, pfini,
                                                           pivalacc, ptdesacc, mensajes);

      IF num_err <> 0 THEN
         vpasexec := 2;
         RAISE e_object_error;
      END IF;

      RETURN num_err;
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
   END f_set_detautriesgos;

-- Bug 9247 - APD - 06/03/2009 -- FinS e crea la funcion f_set_detautriesgos

   -- Bug 9247 - APD - 06/03/2009 -- Se crea la funcion f_elimina_conductor
   /*************************************************************************
      FUNCTION f_elimina_conductor
         Función que elimina del objeto ob_iax_autconductores el conductor indicado
         param in  pnriesgo : número risc
         param in  psperson : número de persona
         param in  pnorden : número de asegurado
         param out mensajes : col·lecció de missatges
         return             : 0 -> Si todo OK
                              1 -> Si ha habido un error
   *************************************************************************/
   FUNCTION f_elimina_conductor(
      pnriesgo IN NUMBER,
      psperson IN NUMBER,
      pnorden IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'parámetros - pnriesgo = ' || pnriesgo || ' - psperson = ' || psperson
            || ' - pnorden = ' || pnorden;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRODUCCION_AUT.f_elimina_conductor';
      vobdetpoliza   ob_iax_detpoliza;
      vobauto        ob_iax_autriesgos;
      vtobconduc     t_iax_autconductores;
   BEGIN
      -- Se validan que los parametros estén informados (el pnriesgo puede ser null (su valor por defecto sera entonces 1))
      IF pnorden IS NULL THEN
         RAISE e_param_error;
      END IF;

      -- Se obtiene el objeto detpoliza
      vobdetpoliza := pac_iobj_prod.f_getpoliza(mensajes);

      IF mensajes IS NOT NULL THEN
         vpasexec := 2;
         RAISE e_object_error;
      END IF;

      -- Se obtiene el objeto autriesgo
      vobauto := pac_iobj_prod.f_partriesautomovil(vobdetpoliza, NVL(pnriesgo, 1), mensajes);

      IF mensajes IS NOT NULL THEN
         vpasexec := 3;
         RAISE e_object_error;
      END IF;

      -- Se obtiene la coleccion autconductores
      vtobconduc := pac_iobj_prod.f_partautconductores(vobauto, mensajes);

      IF mensajes IS NOT NULL THEN
         vpasexec := 4;
         RAISE e_object_error;
      END IF;

      -- Se valida que la coleccion autconductores está informada
      IF vtobconduc IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001462, 'No existen conductores');
         vpasexec := 5;
         RAISE e_object_error;
      ELSE
         IF vtobconduc.COUNT = 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001462,
                                                 'No existen conductores');
            vpasexec := 6;
            RAISE e_object_error;
         END IF;
      END IF;

      IF mensajes IS NOT NULL THEN
         vpasexec := 7;
         RAISE e_object_error;
      END IF;

      vpasexec := 8;

      -- Se elimina el conductor indicado
      FOR vcon IN vtobconduc.FIRST .. vtobconduc.LAST LOOP
         IF vtobconduc.EXISTS(vcon) THEN
            IF vtobconduc(vcon).norden = pnorden THEN
               vtobconduc.DELETE(vcon);
               vobauto.conductores := vtobconduc;
            END IF;
         END IF;
      END LOOP;

      vpasexec := 9;

      IF pac_iax_produccion.poliza.det_poliza.riesgos IS NOT NULL THEN
         IF pac_iax_produccion.poliza.det_poliza.riesgos.COUNT > 0 THEN
            vpasexec := 2;

            FOR i IN
               pac_iax_produccion.poliza.det_poliza.riesgos.FIRST .. pac_iax_produccion.poliza.det_poliza.riesgos.LAST LOOP
               vpasexec := 3;

               IF pac_iax_produccion.poliza.det_poliza.riesgos.EXISTS(i) THEN
                  vpasexec := 4;

                  IF pac_iax_produccion.poliza.det_poliza.riesgos(i).nriesgo = pnriesgo THEN
                     vpasexec := 5;
                     pac_iax_produccion.poliza.det_poliza.riesgos(i).riesautos(1) := vobauto;
                     RETURN 0;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      vpasexec := 10;
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001463,
                                           'No se ha encontrado el conductor');
      RETURN 1;
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
   END f_elimina_conductor;

-- Bug 9247 - APD - 06/03/2009 -- Se crea la funcion f_elimina_conductor

   -- Bug 9247 - APD - 06/03/2009 -- Se crea la funcion f_set_version
   /*************************************************************************
      FUNCTION f_set_version
         Función que inserta en AUT_VERSIONES
         param in  pcversion : Código de la versión
         param in  pcmodelo : Código del modelo.
         param in  pcmarca : Código de la marca.
         param in  pcclaveh : Código clase vehículo.
         param in  pctipveh : Código tipo vehículo
         param in  ptversion : Descripción versión
         param in  ptvarian : Complemento a la versión (en 2ª categoría)
         param in  pnpuerta : Número de puertas totales en turismos.
         param in  pnpuertl : Número de puertas laterales de los furgones
         param in  pnpuertt : Número de puertas traseras de los furgones
         param in  pflanzam : Fecha de lanzamiento. Formato mes/año (mm/aaaa)
         param in  pntara : Peso en vacío
         param in  pnpma : Peso Máximo Admitido
         param in  pnvolcar : Volumen de carga en los furgones
         param in  pnlongit : Longitud del vehículo
         param in  pnvia : Vía delantera
         param in  pnneumat : Anchura de neumático delantero
         param in  pcvehcha : Descriptivo de chasis
         param in  pcvehlog : Descriptivo de longitud
         param in  pcvehacr : Descriptivo de cerramiento
         param in  pcvehcaj : Descriptivo de caja
         param in  pcvehtec : Descriptivo de techo
         param in  pcmotor : Tipo de motor (Gasolina, Diesel,  Eléctrico, etc). Valor fijo 291
         param in  pncilind : Cilindrada del motor
         param in  pnpotecv : Potencia del vehículo
         param in  pnpotekw : Potencia del vehículo
         param in  pnplazas : Número  Máximo de plazas
         param in  pnace100 : Tiempo de aceleración de 0 a 100 Km/h.
         param in  pnace400 : Tiempo de aceleración de 0 a 400 metros
         param in  pnveloc : Velocidad máxima
         param in  pcvehb7 : Indica si viene de base siete o no. Si procede de base siete no se puede modificar los valores. Valor fijo=108
         param out pcversion_out : Código de la versión
         param out mensajes : col·lecció de missatges
         return             : 0 -> Si todo OK
                              1 -> Si ha habido un error
   *************************************************************************/
   FUNCTION f_set_version(
      pcmarca IN VARCHAR2,
      pcmodelo IN VARCHAR2,
      pctipveh IN VARCHAR2,
      pcclaveh IN VARCHAR2,
      pcversion IN VARCHAR2,
      ptversion IN VARCHAR2,
      pnpuerta IN NUMBER,
      pflanzam IN DATE,
      pntara IN NUMBER,
      pnpma IN NUMBER,
      pcmotor IN VARCHAR2,
      pncilind IN NUMBER,
      pnpotecv IN NUMBER,
      pnpotekw IN NUMBER,
      pnplazas IN NUMBER,
      pcvehb7 IN NUMBER,
      pcversion_out OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'parámetros - pcmarca: ' || pcmarca || ' pcmodelo:' || pcmodelo || ' pctipveh:'
            || pctipveh || ' pcclaveh:' || pcclaveh || ' pcversion:' || pcversion
            || ' ptversion:' || ptversion || ' pnpuerta:' || pnpuerta || ' pflanzam:'
            || pflanzam || ' pntara:' || pntara || ' pnpma:' || pnpma || ' pcmotor:'
            || pcmotor || ' pncilind:' || pncilind || ' pnpotecv:' || pnpotecv || ' pnpotekw:'
            || pnpotekw || ' pnplazas:' || pnplazas || ' pcvehb7:' || pcvehb7;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRODUCCION_AUT.f_set_version';
      errores        t_ob_error;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_produccion_aut.f_set_version(pcmarca, pcmodelo, pctipveh, pcclaveh,
                                                     pcversion, ptversion, pnpuerta, pflanzam,
                                                     pntara, pnpma, pcmotor, pncilind,
                                                     pnpotecv, pnpotekw, pnplazas, pcvehb7,
                                                     mensajes);
      vpasexec := 2;

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
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
   END f_set_version;

-- Bug 9247 - APD - 06/03/2009 -- Se crea la funcion f_set_version

   -- Bug 9247 - APD - 06/03/2009 -- Se crea la funcion f_set_AccesoriosNoSerie
   /*************************************************************************
      FUNCTION f_set_AccesoriosNoSerie
         Función que carga el objeto de memoria con los cambios que se realizan en pantalla.
         param in  pnriesgo : número riesgo
         param in  pcversion : número de version
         param in  pcaccesorio : número de accesorio
         param in  ptdescripcion : descripcion del accesorio
         param in  pivalacc : valor del accesorio
         param in  ptipacc : tipo de accesorio
         param out mensajes : col·lecció de missatges
         return             : 0 -> Si todo OK
                              1 -> Si ha habido un error
   *************************************************************************/
   FUNCTION f_set_accesoriosnoserie(
      pnriesgo IN NUMBER,
      pcversion IN VARCHAR2,   --Obligatiro
      pcaccesorio IN VARCHAR2,   -- No obligatorio
      ptdescripcion IN VARCHAR2,
      pivalacc IN NUMBER,
      pctipacc IN NUMBER,
      pcvehb7 IN NUMBER,
      pcmarcado IN NUMBER,
      pcasegurable IN NUMBER,
      pcaccesorio_out OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'parámetros - pnriesgo: ' || pnriesgo || ' pcversion:' || pcversion
            || ' pcaccesorio:' || pcaccesorio || ' ptdescripcion:' || ptdescripcion
            || ' pivalacc:' || pivalacc || ' pctipacc:' || pctipacc;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRODUCCION_AUT.f_set_AccesoriosNoSerie';
      num_err        NUMBER;
      vobaccesorios  ob_iax_autaccesorios;   --Objeto accesorio
      i              NUMBER(3);
      vobdetpoliza   ob_iax_detpoliza;
      vobauto        ob_iax_autriesgos;
      vtobacc        t_iax_autaccesorios;
      v_existe_acc   NUMBER := 0;
   BEGIN
      -- Se obtiene el objeto detpoliza
      vobdetpoliza := pac_iobj_prod.f_getpoliza(mensajes);

      IF mensajes IS NOT NULL THEN
         vpasexec := 2;
         RAISE e_object_error;
      END IF;

      -- Se obtiene el objeto autriesgo
      vobauto := pac_iobj_prod.f_partriesautomovil(vobdetpoliza, NVL(pnriesgo, 1), mensajes);

      IF mensajes IS NOT NULL THEN
         vpasexec := 3;
         RAISE e_object_error;
      END IF;

      -- Se obtiene la coleccion autaccesorios
      vtobacc := pac_iobj_prod.f_partautaccesorios(vobauto, mensajes);

      IF vtobacc IS NULL THEN
         vtobacc := t_iax_autaccesorios();
      END IF;

      IF mensajes IS NOT NULL THEN
         vpasexec := 4;
         RAISE e_object_error;
      END IF;

      vpasexec := 5;

      -- Si el campo caccesorio no viene informado, se está dando de alta un nuevo accesorio no serie
      -- El valor del campo caccesorio se debe calcular
      IF pcaccesorio IS NULL THEN
         vpasexec := 6;
         vtobacc.EXTEND;
         vtobacc(vtobacc.LAST) := ob_iax_autaccesorios();
         vtobacc(vtobacc.LAST).nriesgo := pnriesgo;
         vtobacc(vtobacc.LAST).cversion := pcversion;
         vtobacc(vtobacc.LAST).caccesorio := 'NOGEN' || vtobacc.LAST;
         vtobacc(vtobacc.LAST).taccesorio := 'NOGEN' || vtobacc.LAST;
         vtobacc(vtobacc.LAST).ctipacc := pctipacc;
         vtobacc(vtobacc.LAST).ttipacc := ff_desvalorfijo(292, gidioma, pctipacc);
         vtobacc(vtobacc.LAST).fini := f_sysdate;

         IF vtobacc(vtobacc.LAST).ctipacc = 4
            AND(pivalacc IS NULL
                OR pivalacc <= 0) THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9907453);
            RETURN 1;
         END IF;

         vtobacc(vtobacc.LAST).ivalacc := pivalacc;
         vtobacc(vtobacc.LAST).tdesacc := ptdescripcion;
         vtobacc(vtobacc.LAST).cvehb7 := pcvehb7;
         vtobacc(vtobacc.LAST).cmarcado := pcmarcado;
         vtobacc(vtobacc.LAST).casegurable := pcasegurable;
         num_err :=
            pac_iobj_prod.f_set_partautaccesorios(pac_iax_produccion.poliza.det_poliza,
                                                  pnriesgo, vtobacc, mensajes);

         IF num_err > 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001464,
                                                 'Error al guardar el accesorio');
            RETURN 1;
         END IF;

         vpasexec := 7;
         pcaccesorio_out := vtobacc(vtobacc.LAST).caccesorio;
         vpasexec := 8;
         RETURN 0;
      ELSE   -- pcaccesorio IS NOT NULL --> se está modificando un accesorio no serie
         IF vtobacc.COUNT > 0 THEN
            FOR vacc IN vtobacc.FIRST .. vtobacc.LAST LOOP
               IF vtobacc.EXISTS(vacc) THEN
                  IF /* (vtobacc(vacc).cversion = pcversion or
                      AND*/ vtobacc(vacc).caccesorio = pcaccesorio THEN
                     vtobacc(vacc).nriesgo := pnriesgo;
                     vtobacc(vacc).cversion := pcversion;
                     vtobacc(vacc).caccesorio := pcaccesorio;
                     vtobacc(vacc).taccesorio :=
                                pac_md_listvalores_aut.f_get_taccesorio(pcaccesorio, mensajes);
                     vtobacc(vacc).ctipacc := pctipacc;
                     vtobacc(vacc).ttipacc := ff_desvalorfijo(292, gidioma, pctipacc);

                     IF vtobacc(vacc).ctipacc = 4
                        AND(pivalacc IS NULL
                            OR pivalacc <= 0) THEN
                        pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9907453);
                        RETURN 1;
                     END IF;

                     vtobacc(vacc).ivalacc := pivalacc;
                     vtobacc(vacc).tdesacc := ptdescripcion;
                     vtobacc(vacc).cvehb7 := pcvehb7;
                     vtobacc(vacc).cmarcado := pcmarcado;
                     v_existe_acc := 1;   --si
                     vtobacc(vacc).casegurable := pcasegurable;
                  END IF;
               END IF;
            END LOOP;
         END IF;

         IF v_existe_acc = 0 THEN   -- NO
--            vtobacc := t_iax_autaccesorios();
            vtobacc.EXTEND;
            vtobacc(vtobacc.LAST) := ob_iax_autaccesorios();
            vtobacc(vtobacc.LAST).nriesgo := pnriesgo;
            vtobacc(vtobacc.LAST).cversion := pcversion;
            vtobacc(vtobacc.LAST).caccesorio := pcaccesorio;
            vtobacc(vtobacc.LAST).taccesorio :=
                                pac_md_listvalores_aut.f_get_taccesorio(pcaccesorio, mensajes);
            vtobacc(vtobacc.LAST).ctipacc := pctipacc;
            vtobacc(vtobacc.LAST).ttipacc := ff_desvalorfijo(292, gidioma, pctipacc);
            vtobacc(vtobacc.LAST).fini := f_sysdate;

            IF pctipacc = 4
               AND(pivalacc IS NULL
                   OR pivalacc <= 0) THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9907453);
               RETURN 1;
            END IF;

            vtobacc(vtobacc.LAST).ivalacc := pivalacc;
            vtobacc(vtobacc.LAST).tdesacc := ptdescripcion;
            vtobacc(vtobacc.LAST).cvehb7 := pcvehb7;
            vtobacc(vtobacc.LAST).cmarcado := pcmarcado;
            vtobacc(vtobacc.LAST).casegurable := pcasegurable;
         END IF;

         num_err :=
            pac_iobj_prod.f_set_partautaccesorios(pac_iax_produccion.poliza.det_poliza,
                                                  pnriesgo, vtobacc, mensajes);

         IF num_err > 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001464,
                                                 'Error al guardar el accesorio');
            RETURN 1;
         END IF;

         RETURN 0;
      END IF;

      RETURN num_err;
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
   END f_set_accesoriosnoserie;

   FUNCTION f_set_dispositivonoserie(
      pnriesgo IN NUMBER,
      pcversion IN VARCHAR2,   --Obligatiro
      pcdispositivo IN VARCHAR2,   -- No obligatorio
      pcpropdisp IN VARCHAR2,
      pivaldisp IN NUMBER,
      pfinicontrato IN DATE,
      pffincontrato IN DATE,
      pcmarcado IN NUMBER,
      pncontrato IN NUMBER,
      ptdescdisp IN VARCHAR2,
      pcdispositivo_out OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'parámetros - pnriesgo: ' || pnriesgo || ' pcversion:' || pcversion
            || ' pcdispositivo:' || pcdispositivo || ' ptdescdisp:' || ptdescdisp
            || ' pivaldisp:' || pivaldisp || ' pcpropdisp:' || pcpropdisp;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRODUCCION_AUT.f_set_DISPOSITIVOnoserie';
      num_err        NUMBER;
      vobdispositivo ob_iax_autdispositivos;   --Objeto accesorio
      i              NUMBER(3);
      vobdetpoliza   ob_iax_detpoliza;
      vobauto        ob_iax_autriesgos;
      vtobdisp       t_iax_autdispositivos;
      v_existe_disp  NUMBER := 0;
   BEGIN
      -- Se obtiene el objeto detpoliza
      vobdetpoliza := pac_iobj_prod.f_getpoliza(mensajes);

      IF mensajes IS NOT NULL THEN
         vpasexec := 2;
         RAISE e_object_error;
      END IF;

      -- Se obtiene el objeto autriesgo
      vobauto := pac_iobj_prod.f_partriesautomovil(vobdetpoliza, NVL(pnriesgo, 1), mensajes);

      IF mensajes IS NOT NULL THEN
         vpasexec := 3;
         RAISE e_object_error;
      END IF;

      IF vobauto IS NOT NULL THEN
         IF vobauto.dispositivos IS NOT NULL THEN
            vpasexec := 2;

            IF vobauto.dispositivos.COUNT > 0 THEN
               vpasexec := 3;
               vtobdisp := vobauto.dispositivos;
            END IF;
         END IF;
      END IF;

      IF vtobdisp IS NULL THEN
         vtobdisp := t_iax_autdispositivos();
      END IF;

      IF mensajes IS NOT NULL THEN
         vpasexec := 4;
         RAISE e_object_error;
      END IF;

      vpasexec := 5;

      -- Si el campo cdispesorio no viene informado, se está dando de alta un nuevo dispesorio no serie
      -- El valor del campo cdispesorio se debe calcular
      IF pcdispositivo IS NULL THEN
         vpasexec := 6;
         vtobdisp.EXTEND;
         /* */
         vtobdisp(vtobdisp.LAST) := ob_iax_autdispositivos();
         vtobdisp(vtobdisp.LAST).nriesgo := pnriesgo;
         vtobdisp(vtobdisp.LAST).cversion := pcversion;
         vtobdisp(vtobdisp.LAST).cdispositivo := 'NOGEN' || vtobdisp.LAST;
         vtobdisp(vtobdisp.LAST).tdispositivo := 'NOGEN' || vtobdisp.LAST;
         vtobdisp(vtobdisp.LAST).cpropdisp := pcpropdisp;
         vtobdisp(vtobdisp.LAST).tpropdisp := ff_desvalorfijo(8000912, gidioma, pcpropdisp);
         vtobdisp(vtobdisp.LAST).finicontrato := pfinicontrato;
         vtobdisp(vtobdisp.LAST).ffincontrato := pffincontrato;
         vtobdisp(vtobdisp.LAST).ivaldisp := pivaldisp;
         vtobdisp(vtobdisp.LAST).tdescdisp := ptdescdisp;
         vtobdisp(vtobdisp.LAST).ncontrato := pncontrato;
         vtobdisp(vtobdisp.LAST).cmarcado := pcmarcado;
         num_err :=
            pac_iobj_prod.f_set_partautdispositivos(pac_iax_produccion.poliza.det_poliza,
                                                    pnriesgo, vtobdisp, mensajes);

         IF num_err > 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001464,
                                                 'Error al guardar el dispesorio');
            RETURN 1;
         END IF;

         vpasexec := 7;
         pcdispositivo_out := vtobdisp(vtobdisp.LAST).cdispositivo;
         vpasexec := 8;
         RETURN 0;
      ELSE   -- pcdispesorio IS NOT NULL --> se está modificando un dispesorio no serie
         IF vtobdisp.COUNT > 0 THEN
            FOR vdisp IN vtobdisp.FIRST .. vtobdisp.LAST LOOP
               IF vtobdisp.EXISTS(vdisp) THEN
                  IF /* (vtobdisp(vdisp).cversion = pcversion or
                      AND*/ vtobdisp(vdisp).cdispositivo = pcdispositivo THEN
                     vtobdisp(vdisp).nriesgo := pnriesgo;
                     vtobdisp(vdisp).cversion := pcversion;
                     vtobdisp(vdisp).cdispositivo := pcdispositivo;
                     vtobdisp(vdisp).finicontrato := pfinicontrato;

                     BEGIN
                        SELECT tdispositivo
                          INTO vtobdisp(vdisp).tdispositivo
                          FROM aut_dispositivos
                         WHERE cversion = 0
                           AND cdispositivo = pcdispositivo;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           --INI BUG 0015045 – Fecha (06/01/2015) - HRE - Se modifica para que busque la descripcion del dispositivo con version 1
                           BEGIN
                              SELECT tdispositivo
                                INTO vtobdisp(vdisp).tdispositivo
                                FROM aut_dispositivos
                               WHERE cversion = 1
                                 AND cdispositivo = pcdispositivo;
                           EXCEPTION
                              WHEN NO_DATA_FOUND THEN
                                 vtobdisp(vdisp).tdispositivo := '';
                           END;
                     --FIN BUG 0015045  - Fecha (06/01/2015) – HRE
                     END;

                     vtobdisp(vdisp).cpropdisp := pcpropdisp;
                     vtobdisp(vdisp).tpropdisp := ff_desvalorfijo(8000912, gidioma, pcpropdisp);
                     vtobdisp(vdisp).ivaldisp := pivaldisp;
                     vtobdisp(vdisp).tdescdisp := ptdescdisp;
                     --  vtobdisp(vdisp).cvehb7 := pcvehb7;
                     vtobdisp(vdisp).cmarcado := pcmarcado;
                     v_existe_disp := 1;   --si
                     vtobdisp(vdisp).ncontrato := pncontrato;
                  END IF;
               END IF;
            END LOOP;
         END IF;

         IF v_existe_disp = 0 THEN   -- NO
--            vtobdisp := t_iax_autdispesorios();
            vtobdisp.EXTEND;
            vtobdisp(vtobdisp.LAST) := ob_iax_autdispositivos();
               /*.

                           vtobdisp(vtobdisp.LAST).finicontrato := nvl(pfinicontrato,f_sysdate);
            vtobdisp(vtobdisp.LAST).ffincontrato := pffincontrato;
            vtobdisp(vtobdisp.LAST).ivaldisp := pivaldisp;
            vtobdisp(vtobdisp.LAST).tdescdisp := ptdescdisp;
            vtobdisp(vtobdisp.LAST).ncontrato := pncontrato;
            vtobdisp(vtobdisp.LAST).cmarcado := pcmarcado;*/
            vtobdisp(vtobdisp.LAST).nriesgo := pnriesgo;
            vtobdisp(vtobdisp.LAST).cversion := pcversion;
            vtobdisp(vtobdisp.LAST).cdispositivo := pcdispositivo;

            BEGIN
               SELECT tdispositivo
                 INTO vtobdisp(vtobdisp.LAST).tdispositivo
                 FROM aut_dispositivos
                WHERE cversion = 0
                  AND cdispositivo = pcdispositivo;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  --INI BUG 0015045 – Fecha (06/01/2015) - HRE - Se modifica para que busque la descripcion del dispositivo con version 1
                  BEGIN
                     SELECT tdispositivo
                       INTO vtobdisp(vtobdisp.LAST).tdispositivo
                       FROM aut_dispositivos
                      WHERE cversion = 1
                        AND cdispositivo = pcdispositivo;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        vtobdisp(vtobdisp.LAST).tdispositivo := '';
                  END;
            --FIN BUG 0015045  - Fecha (06/01/2015) – HRE
            END;

            vtobdisp(vtobdisp.LAST).cpropdisp := pcpropdisp;
            vtobdisp(vtobdisp.LAST).tpropdisp := ff_desvalorfijo(8000912, gidioma, pcpropdisp);
            vtobdisp(vtobdisp.LAST).finicontrato := pfinicontrato;
            vtobdisp(vtobdisp.LAST).ivaldisp := pivaldisp;
            vtobdisp(vtobdisp.LAST).tdescdisp := ptdescdisp;
            vtobdisp(vtobdisp.LAST).ncontrato := pncontrato;
            vtobdisp(vtobdisp.LAST).cmarcado := pcmarcado;
            vtobdisp(vtobdisp.LAST).ffincontrato := pffincontrato;
         END IF;

         num_err :=
            pac_iobj_prod.f_set_partautdispositivos(pac_iax_produccion.poliza.det_poliza,
                                                    pnriesgo, vtobdisp, mensajes);

         IF num_err > 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001464,
                                                 'Error al guardar el dispesorio');
            RETURN 1;
         END IF;

         RETURN 0;
      END IF;

      RETURN num_err;
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
   END f_set_dispositivonoserie;

-- Bug 9247 - APD - 06/03/2009 -- Se crea la funcion f_set_AccesoriosNoSerie

   -- Bug 9247 - APD - 09/03/2009 -- Se crea la funcion f_set_conductor
   /*************************************************************************
      FUNCTION f_set_conductor
         Función que carga el objeto de memoria con los cambios que se realizan en pantalla.
         param in  pnriesgo : número riesgo
         param in  pnorden : Numero orden de conductor. El número 1 se corresponde al conductor principal
         param in  psperson : Código de persona (conductor identificado, nominal)
         param in  pfnacimi : Edad conductor innominado
         param in  pnpuntos : Número de puntos en el permiso
         param in  pfcarnet : Fecha de expedición del permiso de conducción
         param in  pcsexo : Sexo conductor innominado
         param in  pexper_manual : Numero de años de experiencia del conductor.
         param in  pexper_cexper : Numero de años de experiencia que viene por interfaz.
         param out mensajes : col·lecció de missatges
         return             : 0 -> Si todo OK
                              1 -> Si ha habido un error

         -- Bug 25368/133447 - 08/01/2013 - AMC  Se añade el pcdomici
         -- Bug 25368/135191 - 15/01/2013 - AMC  Se añade el pcprincipal
   *************************************************************************/
   FUNCTION f_set_conductor(
      pnriesgo IN NUMBER,
      pnorden IN NUMBER,
      psperson IN NUMBER,
      pfnacimi IN DATE,
      pnpuntos IN NUMBER,
      pfcarnet IN DATE,
      pcsexo IN NUMBER,
      pcdomici IN NUMBER,
      pcprincipal IN NUMBER,
      pexper_manual IN NUMBER,
      pexper_cexper IN NUMBER,
      pexper_sinie IN NUMBER,
      pexper_sinie_manual IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'parámetros - pnriesgo: ' || pnriesgo || ' pnorden:' || pnorden || ' psperson:'
            || psperson || ' fnacimi:' || pfnacimi || ' pnpuntos:' || pnpuntos || ' pfcarnet:'
            || pfcarnet || ' pcsexo:' || pcsexo || ' pexper_manual:' || pexper_manual
            || ' pexper_cexper:' || pexper_cexper;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRODUCCION_AUT.f_set_conductor';
      num_err        NUMBER;
   BEGIN
      num_err :=
         pac_md_produccion_aut.f_set_conductor
                                           (pnriesgo, pnorden, psperson, pfnacimi, pnpuntos,
                                            pfcarnet, pcsexo, pcdomici,   -- Bug 25368/133447 - 08/01/2013 - AMC
                                            pcprincipal,   -- Bug 25368/135191 - 15/01/2013 - AMC
                                            pexper_manual, pexper_cexper, pexper_sinie,
                                            pexper_sinie_manual, mensajes);

      IF num_err <> 0 THEN
         vpasexec := 2;
         RAISE e_object_error;
      END IF;

      RETURN num_err;
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
   END f_set_conductor;

-- Bug 9247 - APD - 09/03/2009 -- Se crea la funcion f_set_AccesoriosNoSerie

   -- Bug 9247 - APD - 09/03/2009 -- Se crea la funcion f_set_riesauto
   /*************************************************************************
      FUNCTION f_set_riesauto
         Función que carga el objeto de memoria con los cambios que se realizan en pantalla para el objeto de tipo auto.
         param in  psseguro : Código identificativo del seguro
         param in  pnriesgo : Numero De Riesgo
         param in  pcversion : En Este Campo Tiene La Siguiente Estructura:
         param in  pcmodelo : Código Del Modelo Del Auto.( Se Corresponde Con El Campo Autmodelos.Smodelo)
         param in  pcmarca : Los Cinco Primeros Caracteres Del Campo Cversion.
         param in  pctipveh : Código Del Tipo De Vehículo
         param in  pcclaveh : Código De La Clase De Vehiculo.
         param in  pcmatric : Matricula Vehiculo. No Se Informa Si  Ctipmat = 2, Sin Matricula
         param in  pctipmat : Tipo De Matricula. Tipo De Patente
         param in  pcuso : Codigo Uso Del Vehiculo
         param in  pcsubuso : Codigo Subuso Del Vehiculo
         param in  pfmatric : Fecha de primera matriculación
         param in  pnkilometros : Número de kilómetros anuales. Valor fijo = 295
         param in  pivehicu : Importe Vehiculo
         param in  pnpma : Peso Máximo Autorizado
         param in  pntara : Tara
         param in  pnpuertas : Numero de puertas del vehiculo
         param in  pnplazas : Numero de plazas del vehiculo
         param in  pcmotor : Código del motor
         param in  pcgaraje : Utiliza garaje. Valor fijo = 296
         param in  pcvehb7 : Indica si procede de base siete o no. Valor fijo = 108
         param in  pcusorem : Utiliza remolque . Valor fijo =108 ( si o no )
         param in  pcremolque : Descripción del remolque. Valor fijo =297
         param in  pccolor : Código color vehículo. Valor fijo = 440
         param in  pcvehnue : Indica si el vehículo es nuevo o no.
         param in  pnbastid : Número de bastido( chasis)
         param out  pnriesgo_out : Numero De Riesgo calculado
         param out mensajes : col·lecció de missatges
         param in  pcpeso : Peso del vehiculo
         param in  pctransmision : Transmision del vehiculo
         return             : 0 -> Si todo OK
                              1 -> Si ha habido un error
   *************************************************************************/
   FUNCTION f_set_riesauto(
      psseguro IN NUMBER,   -- Código identificativo del seguro
      pnriesgo IN NUMBER,   --  Numero De Riesgo
      pcversion IN VARCHAR2,   -- En Este Campo Tiene La Siguiente Estructura:
      -- 5 Primeras Posiciones = Marca Del Auto.
      -- Posición 6-7-8 = Modelo Del Auto.
      -- Posición 9-10-11 = Versión Del Auto.
      pcmodelo IN VARCHAR2,   -- Código Del Modelo Del Auto.( Se Corresponde Con El Campo Autmodelos.Smodelo)
      pcmarca IN VARCHAR2,   -- Los Cinco Primeros Caracteres Del Campo Cversion.
      pctipveh IN VARCHAR2,   -- Código Del Tipo De Vehículo
      pcclaveh IN VARCHAR2,   -- Código De La Clase De Vehiculo.
      pcmatric IN VARCHAR2,   -- Matricula Vehiculo. No Se Informa Si  Ctipmat = 2, Sin Matricula
      pctipmat IN NUMBER,   -- Tipo De Matricula. Tipo De Patente
      pcuso IN VARCHAR2,   -- Codigo Uso Del Vehiculo
      pcsubuso IN VARCHAR2,   -- Codigo Subuso Del Vehiculo
      pfmatric IN DATE,   -- Fecha de primera matriculación
      pnkilometros IN NUMBER,   -- Número de kilómetros anuales. Valor fijo = 295
      pivehicu IN NUMBER,   --  Importe Vehiculo
      pnpma IN NUMBER,   --  Peso Máximo Autorizado
      pntara IN NUMBER,   --  Tara
      pnpuertas IN NUMBER,   --  Numero de puertas del vehiculo
      pnplazas IN NUMBER,   --  Numero de plazas del vehiculo
      pcmotor IN NUMBER,   -- Código del motor
      pcgaraje IN NUMBER,   -- Utiliza garaje. Valor fijo = 296
      pcvehb7 IN NUMBER,   -- Indica si procede de base siete o no. Valor fijo = 108
      pcusorem IN NUMBER,   --Utiliza remolque . Valor fijo =108 ( si o no )
      pcremolque IN NUMBER,   -- Descripción del remolque. Valor fijo =297
      pccolor IN NUMBER,   --  Código color vehículo. Valor fijo = 440
      pcvehnue IN NUMBER,   -- Indica si el vehículo es nuevo o no.
      pnbastid IN VARCHAR2,   -- Número de bastido( chasis)
      ptriesgo IN VARCHAR2,
      pcpaisorigen IN NUMBER,
      pcodmotor IN VARCHAR2,
      pcchasis IN VARCHAR2,
      pivehinue IN NUMBER,
      pnkilometraje IN NUMBER,
      pccilindraje IN VARCHAR2,
      pcpintura IN NUMBER,
      pccaja IN NUMBER,
      pccampero IN NUMBER,
      pctipcarroceria IN NUMBER,
      pcservicio IN NUMBER,
      pcorigen IN NUMBER,
      pctransporte IN NUMBER,
      pivehicufasecolda IN NUMBER,
      pivehicufasecoldanue IN NUMBER,
      panyo IN NUMBER,
      pnriesgo_out OUT NUMBER,
      mensajes OUT t_iax_mensajes,
      pffinciant IN DATE DEFAULT NULL,
      pciaant IN NUMBER DEFAULT NULL,
      pcpeso IN NUMBER DEFAULT NULL,
      pctransmision IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      nerr           NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000)
         := 'parámetros -     psseguro      ' || psseguro || '   pnriesgo           '
            || pnriesgo || '   pcversion       ' || pcversion || '   pcmarca            '
            || pcmarca || '   pctipveh           ' || pctipveh || '   pcclaveh           '
            || pcclaveh || '   pcmatric           ' || pcmatric || '   pctipmat           '
            || pctipmat || '   pcuso               ' || pcuso || '   pcsubuso           '
            || pcsubuso || '   pfmatric           ' || pfmatric || '   pnkilometros  '
            || pnkilometros || '   pivehicu           ' || pivehicu
            || '   pnpma                ' || pnpma || '   pntara               ' || pntara
            || '   pnpuertas          ' || pnpuertas || '   pnplazas           ' || pnplazas
            || '   pcmotor         ' || pcmotor || '   pcgaraje        ' || pcgaraje
            || '   pcvehb7         ' || pcvehb7 || '   pcusorem         ' || pcusorem
            || '   pcremolque       ' || pcremolque || '   pccolor          ' || pccolor
            || '   pcvehnue           ' || pcvehnue || '   pnbastid           ' || pnbastid
            || '   ptriesgo           ' || ptriesgo || '   pffinciant     ' || pffinciant
            || '   pciaant    ' || pciaant || '   pcpeso           ' || pcpeso
            || '   pctransmision     ' || pctransmision;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRODUCCION_AUT.f_set_riesauto';
      v_nriesgo_out  NUMBER;
      num_err        NUMBER;
   BEGIN
      num_err :=
         pac_md_produccion_aut.f_set_riesauto
            (psseguro,   -- Código identificativo del seguro
             pnriesgo,   --  Numero De Riesgo
             pcversion,   -- En Este Campo Tiene La Siguiente Estructura:
             pcmodelo,   -- Código Del Modelo Del Auto.( Se Corresponde Con El Campo Autmodelos.Smodelo)
             pcmarca,   -- Los Cinco Primeros Caracteres Del Campo Cversion.
             pctipveh,   -- Código Del Tipo De Vehículo
             pcclaveh,   -- Código De La Clase De Vehiculo.
             pcmatric,   -- Matricula Vehiculo. No Se Informa Si  Ctipmat = 2, Sin Matricula
             pctipmat,   -- Tipo De Matricula. Tipo De Patente
             pcuso,   -- Codigo Uso Del Vehiculo
             pcsubuso,   -- Codigo Subuso Del Vehiculo
             pfmatric,   -- Fecha de primera matriculación
             pnkilometros,   -- Número de kilómetros anuales. Valor fijo = 295
             pivehicu,   --  Importe Vehiculo
             pnpma,   --  Peso Máximo Autorizado
             pntara,   --  Tara
             pnpuertas,   --  Numero de puertas del vehiculo
             pnplazas,   --  Numero de plazas del vehiculo
             pcmotor,   -- Código del motor
             pcgaraje,   -- Utiliza garaje. Valor fijo = 296
             pcvehb7,   -- Indica si procede de base siete o no. Valor fijo = 108
             pcusorem,   --Utiliza remolque . Valor fijo =108 ( si o no )
             pcremolque,   -- Descripción del remolque. Valor fijo =297
             pccolor,   --  Código color vehículo. Valor fijo = 440
             pcvehnue,   -- Indica si el vehículo es nuevo o no.
             pnbastid,   -- Número de bastido( chasis)
             ptriesgo, pcpaisorigen, pcodmotor, pcchasis, pivehinue, pnkilometraje,
             pccilindraje, pcpintura, pccaja, pccampero, pctipcarroceria, pcservicio,
             pcorigen, pctransporte, pivehicufasecolda, pivehicufasecoldanue, panyo,
             v_nriesgo_out, mensajes, pffinciant, pciaant, pcpeso, pctransmision);

      IF num_err <> 0 THEN
         vpasexec := 2;
         RAISE e_object_error;
      END IF;

      -- Se devuelve el valor del nriesgo por si se ha tenido que calcular
      pnriesgo_out := v_nriesgo_out;
      RETURN num_err;
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
   END f_set_riesauto;

-- Bug 9247 - APD - 09/03/2009 -- Se crea la funcion f_set_riesauto

   -- Bug 9247 - APD - 10/03/2009 -- Se crea la funcion f_grabaconductores
   -- Bug 25368/133447 - 08/01/2013 - AMC  Se añade el pcdomici
   -- Bug 25368/135191 - 15/01/2013 - AMC  Se añade el pcprincipal
   FUNCTION f_grabaconductores(
      pnriesgo IN NUMBER,   -- Numero de riesgo
      psperson IN NUMBER,   -- Identificador de la persona
      pnpuntos IN NUMBER,   -- Numero de puntos
      pfcarnet IN DATE,   -- Fecha carnet
      pcdomici IN NUMBER,
      pcprincipal IN NUMBER,
      pexper_manual IN NUMBER,
      pexper_cexper IN NUMBER,
      pexper_sinie IN NUMBER,
      pexper_sinie_manual IN NUMBER,
      pnorden IN NUMBER DEFAULT 0,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'parámetros - pnriesgo: ' || pnriesgo || ' psperson:' || psperson || ' pnpuntos:'
            || pnpuntos || ' pfcarnet:' || pfcarnet || ' pexper_manual:' || pexper_manual
            || ' pexper_cexper:' || pexper_cexper;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRODUCCION_AUT.f_grabaconductores';
      errores        t_ob_error;
      vobdetpoliza   ob_iax_detpoliza;
      vobautries     ob_iax_autriesgos;
      vtobconduc     t_iax_autconductores;
      vfnacimi       DATE;
      vcsexo         NUMBER(3);
      num_err        NUMBER(3);
   BEGIN
      vpasexec := 1;

      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      IF pnriesgo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vobdetpoliza := pac_iobj_prod.f_getpoliza(mensajes);
      vpasexec := 4;

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            vpasexec := 5;
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 6;
      vobautries := pac_iobj_prod.f_partriesautomovil(vobdetpoliza, pnriesgo, mensajes);
      vpasexec := 7;

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            vpasexec := 8;
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 9;
      -- Se obtiene la coleccion autconductores
      vtobconduc := pac_iobj_prod.f_partautconductores(vobautries, mensajes);
      vpasexec := 10;

      -- Se valida que la coleccion autconductores está informada
      IF vtobconduc IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001462, 'No existen conductores');
         vpasexec := 11;
         RAISE e_object_error;
      END IF;

      vpasexec := 12;

      IF vtobconduc.COUNT = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001462, 'No existen conductores');
         vpasexec := 13;
         RAISE e_object_error;
      END IF;

      vpasexec := 14;

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            vpasexec := 15;
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 16;

      -- Se busca la edad y el sexo del conductor
      FOR vcon IN vtobconduc.FIRST .. vtobconduc.LAST LOOP
         IF vtobconduc.EXISTS(vcon) THEN
            IF vtobconduc(vcon).sperson = psperson THEN
               vfnacimi := vtobconduc(vcon).fnacimi;
               vcsexo := vtobconduc(vcon).csexo;
            END IF;
         END IF;
      END LOOP;

      vpasexec := 20;
      num_err := f_set_conductor(pnriesgo, pnorden, psperson, vfnacimi, pnpuntos, pfcarnet,
                                 vcsexo, pcdomici,   -- Bug 25368/133447 - 08/01/2013 - AMC
                                 pcprincipal,   -- Bug 25368/135191 - 15/01/2013 - AMC
                                 pexper_manual, pexper_cexper, pexper_sinie,
                                 pexper_sinie_manual, mensajes);

      IF num_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 30;
      num_err := pac_md_validaciones_aut.f_validaconductores(vobautries, mensajes);

      IF num_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      pac_iax_produccion.poliza.det_poliza.p_set_needtarificar(1);
      vpasexec := 40;
      RETURN 0;
-----------------------
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
   END f_grabaconductores;

-- Bug 9247 - APD - 10/03/2009 -- Se crea la funcion f_grabaconductores

   -- Bug 9247 - APD - 23/03/2009 -- Se crea la funcion f_set_garanmodalidad
   /*************************************************************************
    Recupera las garantías que contiene una modalidad.
    param in p_nriesgo: identificador del riesgo
    param in p_cmodalidad: codigo de la modalidad
    param out garantaias: coleccion de garantias
    param out mensajes: mensajes de error
    return : ref cursor
    *************************************************************************/
   FUNCTION f_set_garanmodalidad(
      p_nriesgo IN NUMBER,
      p_cmodalidad IN NUMBER,
      garantias OUT t_iax_garantias,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(2000)
                         := 'p_nriesgo = ' || p_nriesgo || '; p_cmodalidad = ' || p_cmodalidad;
      v_object       VARCHAR2(200) := 'PAC_IAX_PRODUCCION_AUT.f_set_garanmodalidad';
      vsolicit       NUMBER;
      vnmovimi       NUMBER;
      vpmode         VARCHAR2(100);
      nerr           NUMBER;
   BEGIN
      vsolicit := pac_iax_produccion.vsolicit;
      vnmovimi := pac_iax_produccion.vnmovimi;
      vpmode := pac_iax_produccion.vpmode;
      nerr := pac_md_produccion_aut.f_set_garanmodalidad(p_nriesgo, p_cmodalidad, vsolicit,
                                                         vnmovimi, vpmode, garantias,
                                                         mensajes);
      RETURN nerr;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_garanmodalidad;

-- Bug 9247 - APD - 23/03/2009 -- Se crea la funcion f_set_garanmodalidad

   --BUG: 0027953/0151258 - JSV 21/08/2013 - INI
   /*************************************************************************
    Recupera las garantías que contiene una modalidad.
    param in p_nriesgo: identificador del riesgo
    param in p_cmodalidad: codigo de la modalidad
    param out garantaias: coleccion de garantias
    param out mensajes: mensajes de error
    return : ref cursor
    *************************************************************************/
   FUNCTION f_get_garanmodalidad(
      p_nriesgo IN NUMBER,
      p_cmodalidad IN NUMBER,
      garantias OUT t_iax_garantias,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(2000)
                         := 'p_nriesgo = ' || p_nriesgo || '; p_cmodalidad = ' || p_cmodalidad;
      v_object       VARCHAR2(200) := 'PAC_IAX_PRODUCCION_AUT.f_get_garanmodalidad';
      vsolicit       NUMBER;
      vnmovimi       NUMBER;
      vpmode         VARCHAR2(100);
      nerr           NUMBER;
   BEGIN
      vsolicit := pac_iax_produccion.vsolicit;
      vnmovimi := pac_iax_produccion.vnmovimi;
      vpmode := pac_iax_produccion.vpmode;
      nerr := pac_md_produccion_aut.f_get_garanmodalidad(p_nriesgo, p_cmodalidad, vsolicit,
                                                         vnmovimi, vpmode, garantias,
                                                         mensajes);
      RETURN nerr;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_garanmodalidad;

--BUG: 0027953/0151258 - JSV 21/08/2013 - FIN

   /*************************************************************************
      FUNCTION f_lee_accesorios
         Funció que retorna los accesorios no serie del riesgo
         param in pnriesgo : número risc
         param out mensajes : col·lecció de missatges
         return             : col·lecció d'accesoris (t_iax_autaccesorios)
   *************************************************************************/
   FUNCTION f_lee_accesorios(pnriesgo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iax_autaccesorios IS
      vobauto        ob_iax_autriesgos;
      vobdetpoliza   ob_iax_detpoliza;
      vobriesgos     ob_iax_riesgos;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000) := 'parámetros - pnriesgo: ' || pnriesgo;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRODUCCION_AUT.f_lee_accesorios';
   BEGIN
      vobdetpoliza := pac_iobj_prod.f_getpoliza(mensajes);

      IF vobdetpoliza IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 140897,
                                              'Error al buscar la poliza');
         vpasexec := 1;
         RAISE e_object_error;
      END IF;

      IF mensajes IS NOT NULL THEN
         vpasexec := 2;
         RAISE e_object_error;
      END IF;

      vobriesgos := pac_iobj_prod.f_partpolriesgo(vobdetpoliza, pnriesgo, mensajes);

      IF vobriesgos IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000441,
                                              'No existen riesgos asociados a la póliza');
         vpasexec := 3;
         RAISE e_object_error;
      END IF;

      IF mensajes IS NOT NULL THEN
         vpasexec := 4;
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      vobauto := pac_iobj_prod.f_partriesautomoviles(vobriesgos, mensajes);

      IF vobauto IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001465,
                                              'No existen autos asociados a la póliza');
         vpasexec := 6;
         RAISE e_object_error;
      END IF;

      IF mensajes IS NOT NULL THEN
         vpasexec := 7;
         RAISE e_object_error;
      END IF;

      taccesorios := pac_iobj_prod.f_partautaccesorios(vobauto, mensajes);

      IF mensajes IS NOT NULL THEN
         vpasexec := 8;
         RAISE e_object_error;
      END IF;

      RETURN taccesorios;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_lee_accesorios;

   FUNCTION f_lee_dispositivos(pnriesgo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iax_autdispositivos IS
      vobauto        ob_iax_autriesgos;
      vobdetpoliza   ob_iax_detpoliza;
      vobriesgos     ob_iax_riesgos;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000) := 'parámetros - pnriesgo: ' || pnriesgo;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRODUCCION_AUT.f_lee_dispositivos';
   BEGIN
      vobdetpoliza := pac_iobj_prod.f_getpoliza(mensajes);

      IF vobdetpoliza IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 140897,
                                              'Error al buscar la poliza');
         vpasexec := 1;
         RAISE e_object_error;
      END IF;

      IF mensajes IS NOT NULL THEN
         vpasexec := 2;
         RAISE e_object_error;
      END IF;

      vobriesgos := pac_iobj_prod.f_partpolriesgo(vobdetpoliza, pnriesgo, mensajes);

      IF vobriesgos IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000441,
                                              'No existen riesgos asociados a la póliza');
         vpasexec := 3;
         RAISE e_object_error;
      END IF;

      IF mensajes IS NOT NULL THEN
         vpasexec := 4;
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      vobauto := pac_iobj_prod.f_partriesautomoviles(vobriesgos, mensajes);

      IF vobauto IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001465,
                                              'No existen autos asociados a la póliza');
         vpasexec := 6;
         RAISE e_object_error;
      END IF;

      IF mensajes IS NOT NULL THEN
         vpasexec := 7;
         RAISE e_object_error;
      END IF;

      --   taccesorios := pac_iobj_prod.f_partautaccesorios(vobauto, mensajes);
      IF vobauto IS NOT NULL THEN
         IF vobauto.dispositivos IS NOT NULL THEN
            vpasexec := 2;

            IF vobauto.dispositivos.COUNT > 0 THEN
               vpasexec := 3;
               RETURN vobauto.dispositivos;
            END IF;
         END IF;
      END IF;

      RETURN NULL;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_lee_dispositivos;

   /*************************************************************************
      FUNCTION f_lee_accesoriosnoserie
         Funció que retorna los accesorios no serie de la version
         param in pcversion : código de versión
         param out mensajes : col·lecció de missatges
         return             : col·lecció d'accesoris (t_iax_autaccesorios)
   *************************************************************************/
   FUNCTION f_lee_accesoriosnoserie(pcversion IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN t_iax_autaccesorios IS
      reg            sys_refcursor;
      taccesorios    t_iax_autaccesorios := t_iax_autaccesorios();
      accesorio      ob_iax_autaccesorios := ob_iax_autaccesorios();
      datos          aut_accesorios%ROWTYPE;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000) := 'parámetros - pcversion: ' || pcversion;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRODUCCION_AUT.f_lee_accesoriosnoserie';
   BEGIN
      reg := pac_md_listvalores_aut.f_get_lstaccesoriosnoserie(pcversion, mensajes);

      LOOP
         FETCH reg
          INTO datos.cversion, datos.caccesorio, datos.copcpack, datos.taccesorio,
               datos.cmoneda, datos.ivalpubl, datos.iivalfabrica, datos.finicio, datos.ffin,
               datos.cactivo, datos.cvehb7;

         EXIT WHEN reg%NOTFOUND;
         accesorio.sseguro := NULL;
         accesorio.nriesgo := NULL;
         accesorio.nmovimi := NULL;
         accesorio.cversion := pcversion;
         accesorio.caccesorio := datos.caccesorio;
         accesorio.ctipacc := NULL;
         accesorio.ttipacc := NULL;
         accesorio.fini := datos.finicio;
         accesorio.ivalacc := datos.ivalpubl;
         accesorio.tdesacc := datos.taccesorio;
         accesorio.cvehb7 := 1;
         taccesorios.EXTEND;
         taccesorios(taccesorios.LAST) := accesorio;
         accesorio := ob_iax_autaccesorios();
      END LOOP;

      RETURN taccesorios;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_lee_accesoriosnoserie;

   FUNCTION f_lee_dispositivosnoserie(pcversion IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN t_iax_autdispositivos IS
      cur            sys_refcursor;
      dispositius    t_iax_autdispositivos := t_iax_autdispositivos();
      dispositivo    ob_iax_autdispositivos := ob_iax_autdispositivos();
      datos          aut_accesorios%ROWTYPE;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000) := 'parámetros - pcversion: ' || pcversion;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRODUCCION_AUT.f_lee_dispositivosnoserie';
      vsseguro       NUMBER;
      vnriesgo       NUMBER(6);
      vnmovimi       NUMBER(4);
      vcversion      VARCHAR2(11);
      vcmarcado      NUMBER(1);
      vcdispositivo  VARCHAR2(10);
      vcpropdisp     NUMBER;
      vtpropdisp     VARCHAR2(200);
      vfinicontrato  DATE;
      vffincontrato  DATE;
      vivaldisp      NUMBER;
      vtdesdisp      NUMBER;
      vncontrato     VARCHAR2(100);
      vtdispositivo  VARCHAR2(1000);
      vcmoneda       NUMBER;
      vivalpubl      NUMBER;
      viivalfabrica  NUMBER;
      vfinicio       DATE;
      vffin          DATE;
      vcactivo       VARCHAR2(2);
      vcvehb7        NUMBER;
      vcpropdis      NUMBER(8);
   BEGIN
      cur := pac_md_listvalores_aut.f_get_lstdispositivosnoserie(pcversion, mensajes);

      LOOP
         FETCH cur
          INTO vcversion, vcdispositivo, vtdispositivo, vcmoneda, vivalpubl, viivalfabrica,
               vfinicio, vffin, vcactivo, vcvehb7, vcpropdis;

         -- BUG15824:DRA:07/09/2010
         EXIT WHEN cur%NOTFOUND;
         dispositius.EXTEND;
         dispositius(dispositius.LAST) := ob_iax_autdispositivos();
         --BUG 9247-24022009-XVM
         dispositius(dispositius.LAST).sseguro := NULL;
         dispositius(dispositius.LAST).nriesgo := NULL;
         dispositius(dispositius.LAST).nmovimi := NULL;
         dispositius(dispositius.LAST).cversion := vcversion;
         dispositius(dispositius.LAST).cdispositivo := vcdispositivo;
         dispositius(dispositius.LAST).tdispositivo := vtdispositivo;
         dispositius(dispositius.LAST).cpropdisp := vcpropdisp;

         IF vcpropdisp IS NOT NULL THEN
            vtpropdisp := pac_md_listvalores.f_getdescripvalores(8000912, vcpropdisp,
                                                                 mensajes);
         END IF;

         dispositius(dispositius.LAST).tpropdisp := vtpropdisp;
         dispositius(dispositius.LAST).finicontrato := vfinicio;
         dispositius(dispositius.LAST).ffincontrato := NULL;
         dispositius(dispositius.LAST).ivaldisp := vivalpubl;
         dispositius(dispositius.LAST).tdescdisp := '';
         --    dispositius(dispositius.LAST).cmarcado := vcmarcado;
         dispositius(dispositius.LAST).ncontrato := NULL;
      END LOOP;

      RETURN dispositius;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_lee_dispositivosnoserie;

   FUNCTION f_del_accesoriosnoserie(
      pnriesgo IN NUMBER,
      pcversion IN VARCHAR2,
      pcaccesorio IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'parámetros - pnriesgo: ' || pnriesgo || ' pcversion:' || pcversion
            || ' pcaccesorio:' || pcaccesorio;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRODUCCION_AUT.f_del_AccesoriosNoSerie';
      num_err        NUMBER;
      vobaccesorios  ob_iax_autaccesorios;   --Objeto accesorio
      i              NUMBER(3);
      vobdetpoliza   ob_iax_detpoliza;
      vobauto        ob_iax_autriesgos;
      vtobacc        t_iax_autaccesorios;
      v_existe_acc   NUMBER := 0;
   BEGIN
      -- Se obtiene el objeto detpoliza
      vobdetpoliza := pac_iobj_prod.f_getpoliza(mensajes);

      IF mensajes IS NOT NULL THEN
         vpasexec := 2;
         RAISE e_object_error;
      END IF;

      -- Se obtiene el objeto autriesgo
      vobauto := pac_iobj_prod.f_partriesautomovil(vobdetpoliza, NVL(pnriesgo, 1), mensajes);

      IF mensajes IS NOT NULL THEN
         vpasexec := 3;
         RAISE e_object_error;
      END IF;

      -- Se obtiene la coleccion autaccesorios
      vtobacc := pac_iobj_prod.f_partautaccesorios(vobauto, mensajes);

      IF vtobacc IS NULL THEN
         vtobacc := t_iax_autaccesorios();
      END IF;

      IF mensajes IS NOT NULL THEN
         vpasexec := 4;
         RAISE e_object_error;
      END IF;

      vpasexec := 5;

      -- Si el campo caccesorio no viene informado, se está dando de alta un nuevo accesorio no serie
      -- El valor del campo caccesorio se debe calcular
      IF pcaccesorio IS NOT NULL THEN
         -- pcaccesorio IS NOT NULL --> se está modificando un accesorio no serie
         IF vtobacc.COUNT > 0 THEN
            FOR vacc IN vtobacc.FIRST .. vtobacc.LAST LOOP
               IF vtobacc.EXISTS(vacc) THEN
                  IF vtobacc(vacc).caccesorio = pcaccesorio THEN
                     vtobacc.DELETE(vacc);
                  END IF;
               END IF;
            END LOOP;
         END IF;

         num_err :=
            pac_iobj_prod.f_set_partautaccesorios(pac_iax_produccion.poliza.det_poliza,
                                                  pnriesgo, vtobacc, mensajes);

         IF num_err > 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001464,
                                                 'Error al guardar el accesorio');
            RETURN 1;
         END IF;

         RETURN 0;
      END IF;

      RETURN num_err;
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
   END f_del_accesoriosnoserie;

   FUNCTION f_del_dispositivosnoserie(
      pnriesgo IN NUMBER,
      pcversion IN VARCHAR2,
      pcdispositivo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'parámetros - pnriesgo: ' || pnriesgo || ' pcversion:' || pcversion
            || ' pcdispositivo:' || pcdispositivo;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRODUCCION_AUT.f_del_dispositivosNoSerie';
      num_err        NUMBER;
      vobdispositivos ob_iax_autdispositivos;   --Objeto dispositivo
      i              NUMBER(3);
      vobdetpoliza   ob_iax_detpoliza;
      vobauto        ob_iax_autriesgos;
      vtobacc        t_iax_autdispositivos;
      v_existe_acc   NUMBER := 0;
   BEGIN
      -- Se obtiene el objeto detpoliza
      vobdetpoliza := pac_iobj_prod.f_getpoliza(mensajes);

      IF mensajes IS NOT NULL THEN
         vpasexec := 2;
         RAISE e_object_error;
      END IF;

      -- Se obtiene el objeto autriesgo
      vobauto := pac_iobj_prod.f_partriesautomovil(vobdetpoliza, NVL(pnriesgo, 1), mensajes);

      IF mensajes IS NOT NULL THEN
         vpasexec := 3;
         RAISE e_object_error;
      END IF;

      IF vobauto IS NOT NULL THEN
         IF vobauto.dispositivos IS NOT NULL THEN
            vpasexec := 2;

            IF vobauto.dispositivos.COUNT > 0 THEN
               vpasexec := 3;
               vtobacc := vobauto.dispositivos;
            END IF;
         END IF;
      END IF;

      IF vtobacc IS NULL THEN
         vtobacc := t_iax_autdispositivos();
      END IF;

      IF mensajes IS NOT NULL THEN
         vpasexec := 4;
         RAISE e_object_error;
      END IF;

      vpasexec := 5;

      -- Si el campo cdispositivo no viene informado, se está dando de alta un nuevo dispositivo no serie
      -- El valor del campo cdispositivo se debe calcular
      IF pcdispositivo IS NOT NULL THEN
         -- pcdispositivo IS NOT NULL --> se está modificando un dispositivo no serie
         IF vtobacc.COUNT > 0 THEN
            FOR vacc IN vtobacc.FIRST .. vtobacc.LAST LOOP
               IF vtobacc.EXISTS(vacc) THEN
                  IF vtobacc(vacc).cdispositivo = pcdispositivo THEN
                     vtobacc.DELETE(vacc);
                  END IF;
               END IF;
            END LOOP;
         END IF;

         num_err :=
            pac_iobj_prod.f_set_partautdispositivos(pac_iax_produccion.poliza.det_poliza,
                                                    pnriesgo, vtobacc, mensajes);

         IF num_err > 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001464,
                                                 'Error al eliminar el dispositivo');
            RETURN 1;
         END IF;

         RETURN 0;
      END IF;

      RETURN num_err;
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
   END f_del_dispositivosnoserie;

   FUNCTION f_get_auto_matric(
      pctipmat IN NUMBER,
      pcmatric IN VARCHAR2,
      psproduc IN NUMBER,   -- Bug 26435/142193 - 03/05/2013 - AMC
      pcactivi IN NUMBER,   -- Bug 26435/142193 - 03/05/2013 - AMC
      pcmodo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_autriesgos IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
                         := 'parámetros - pctipmat: ' || pctipmat || ',pcmatric: ' || pcmatric;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRODUCCION_AUT.f_get_auto_matric';
      num_err        NUMBER;
      cur            sys_refcursor;
      v_tsquery      VARCHAR2(3000);
      riesgauto      ob_iax_autriesgos;
      pcaccesorio    VARCHAR2(1000);
      pcdispositivo  VARCHAR2(1000);
   BEGIN
      riesgauto := pac_md_produccion_aut.f_get_auto_matric(pctipmat, pcmatric, psproduc,
                                                           pcactivi, pcmodo, mensajes);

      IF NVL(f_parproductos_v(psproduc, 'CARGAR_AUTO'), 0) = 1 THEN
         IF (riesgauto.accesorios IS NULL) THEN
            num_err :=
               pac_iobj_prod.f_set_partautaccesorios(pac_iax_produccion.poliza.det_poliza,
                                                     NVL(riesgauto.nriesgo, 1),
                                                     riesgauto.accesorios, mensajes);
         ELSE
            -- Bug 32009/0188727 - APD - 03/10/2014 - se añade riesgauto.accesorios.COUNT <> 0
            IF riesgauto.accesorios.COUNT <> 0 THEN
               FOR reg IN riesgauto.accesorios.FIRST .. riesgauto.accesorios.LAST LOOP
                  num_err :=
                     pac_iax_produccion_aut.f_set_accesoriosnoserie
                                                     (NVL(riesgauto.accesorios(reg).nriesgo,
                                                          1),
                                                      riesgauto.accesorios(reg).cversion,
                                                      riesgauto.accesorios(reg).caccesorio,
                                                      riesgauto.accesorios(reg).tdesacc,
                                                      riesgauto.accesorios(reg).ivalacc,
                                                      riesgauto.accesorios(reg).ctipacc,
                                                      riesgauto.accesorios(reg).cvehb7,
                                                      riesgauto.accesorios(reg).cmarcado,
                                                      riesgauto.accesorios(reg).casegurable,
                                                      pcaccesorio, mensajes);
               END LOOP;
            END IF;
         -- fin Bug 32009/0188727 - APD - 03/10/2014
         END IF;

         IF (riesgauto.dispositivos IS NULL) THEN
            num_err :=
               pac_iobj_prod.f_set_partautdispositivos(pac_iax_produccion.poliza.det_poliza,
                                                       NVL(riesgauto.nriesgo, 1),
                                                       riesgauto.dispositivos, mensajes);
         ELSE
            -- Bug 32009/0188727 - APD - 03/10/2014 - se añade riesgauto.dispositivos.COUNT <> 0
            IF riesgauto.dispositivos.COUNT <> 0 THEN
               FOR reg IN riesgauto.dispositivos.FIRST .. riesgauto.dispositivos.LAST LOOP
                  num_err :=
                     pac_iax_produccion_aut.f_set_dispositivonoserie
                                                   (NVL(riesgauto.dispositivos(reg).nriesgo,
                                                        1),
                                                    riesgauto.dispositivos(reg).cversion,
                                                    riesgauto.dispositivos(reg).cdispositivo,
                                                    riesgauto.dispositivos(reg).cpropdisp,
                                                    riesgauto.dispositivos(reg).ivaldisp,
                                                    riesgauto.dispositivos(reg).finicontrato,
                                                    riesgauto.dispositivos(reg).ffincontrato,
                                                    riesgauto.dispositivos(reg).cmarcado,
                                                    riesgauto.dispositivos(reg).ncontrato,
                                                    riesgauto.dispositivos(reg).tdescdisp,
                                                    pcdispositivo, mensajes);
               END LOOP;
            END IF;
         -- fin Bug 32009/0188727 - APD - 03/10/2014
         END IF;
      END IF;

      RETURN riesgauto;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_auto_matric;

   FUNCTION f_hay_homologacion(
      pcversion IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pvalorcomercial OUT NUMBER,
      pvalorcomercial_nuevo OUT NUMBER,
      phomologado OUT NUMBER,
      pmensajemostrar OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vcversionhomologo aut_versiones.cversionhomologo%TYPE;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'parámetros - pcversion: ' || pcversion || ',psseguro: ' || psseguro
            || ',pnriesgo: ' || pnriesgo;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRODUCCION_AUT.f_hay_homologacion';
   BEGIN
      phomologado := pac_md_produccion_aut.f_hay_homologacion(pcversion, psseguro, pnriesgo,
                                                              pvalorcomercial,
                                                              pvalorcomercial_nuevo,
                                                              phomologado, pmensajemostrar,
                                                              mensajes);
      RETURN phomologado;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         phomologado := 0;
         RETURN phomologado;
   END f_hay_homologacion;

   --BUG: 26635  LCOL - AUT - Cotnrol de duplicidad de Autos.
   FUNCTION f_controlduplicidad(
      psseguro IN NUMBER,   -- Código identificativo del seguro
      pcmatric IN VARCHAR2,   -- Matricula Vehiculo. No Se Informa Si  Ctipmat = 2, Sin Matricula
      pnbastid IN VARCHAR2,
      pcchasis IN VARCHAR2,   -- Código de chasis
      pcodmotor IN VARCHAR2,   -- Código del motor
      psproduc IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vobdetpoliza   ob_iax_detpoliza;
      vreemplazos    t_iax_reemplazos;
      vparam         VARCHAR2(4000)
         := 'parámetros - psseguro: ' || psseguro || ' pcmatric: ' || pcmatric
            || ' pnbastid: ' || pnbastid || ' pcchasis: ' || pcchasis || ' pcodmotor: '
            || pcodmotor || ' psproduc: ' || psproduc;
      vobject        VARCHAR2(200) := 'pac_md_autos.f_controlduplicidad';
      nerror         NUMBER;
      v_cvalpar      NUMBER;
      vtrobat_reemplazo NUMBER := 0;
      vefectsuple    DATE := NULL;   -- Bug 32009/0188870 - APD - 07/10/2014
   BEGIN
      nerror := f_parproductos(psproduc, 'POLIZA_UNICA_SIMUL', v_cvalpar);

      IF nerror <> 0 THEN
         RETURN nerror;
      END IF;

      --Validamos que no haya duplicidad de matrículas, vin o código del motor.
      IF pac_iax_produccion.issimul = FALSE
         OR(v_cvalpar = 1
            AND pac_iax_produccion.issimul = TRUE) THEN
         nerror := f_parproductos(psproduc, 'POLIZA_UNICA', v_cvalpar);

         IF nerror <> 0 THEN
            RETURN nerror;
         END IF;

         IF NVL(v_cvalpar, 0) = 5 THEN   --Bug 26435/165053 - 03/02/2014 - AMC
            -- Miramos si la póliza viene de un reemplazo.
            -- Si viene de un reemplazo no miramos la duplicidad.
            vobdetpoliza := pac_iobj_prod.f_getpoliza(mensajes);

            IF mensajes IS NOT NULL THEN
               vpasexec := 2;
               RAISE e_object_error;
            END IF;

            vreemplazos := pac_iobj_prod.f_partpolreemplazos(vobdetpoliza, mensajes);

            IF mensajes IS NOT NULL THEN
               vpasexec := 2;
               RAISE e_object_error;
            END IF;

            IF vreemplazos IS NOT NULL THEN
               IF vreemplazos.COUNT > 0 THEN
                  FOR i IN 1 .. vreemplazos.LAST LOOP
                     IF vreemplazos(i).sseguro = vobdetpoliza.sseguro THEN
                        -- poliza que viene de un reemplazo
                        vtrobat_reemplazo := 1;
                     END IF;
                  END LOOP;
               END IF;
            END IF;

            --por cumulo
            --BUG 26435 - INICIO - DCT - 15/03/2013 - Añadir pcchasis
            IF vtrobat_reemplazo = 0 THEN
               -- Bug 32009/0188870 - APD - 07/10/2014 - en caso de suplemento se debe buscar
               -- la fecha de efecto del suplemento
               IF pac_iax_produccion.issuplem THEN
                  nerror := pac_md_suplementos.f_get_fefecto_supl(NVL(psseguro,
                                                                      vobdetpoliza.sseguro),
                                                                  vobdetpoliza.nmovimi,
                                                                  vefectsuple, mensajes);

                  IF (nerror <> 0) THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000827);
                     RAISE e_object_error;
                  END IF;
               END IF;

               -- fin Bug 32009/0188870 - APD - 07/10/2014

               -- Bug 32009/0188870 - APD - 07/10/2014 - se sustituye pac_iax_produccion.vfefecto por
               --  NVL(vefectsuple,pac_iax_produccion.vfefecto)
               vnumerr := pac_md_autos.f_controlduplicidad(NVL(psseguro, vobdetpoliza.sseguro),
                                                           pcmatric, pnbastid, pcchasis,
                                                           pcodmotor, psproduc,
                                                           NVL(vefectsuple,
                                                               pac_iax_produccion.vfefecto),
                                                           mensajes);
            -- fin Bug 32009/0188870 - APD - 07/10/2014
            END IF;
         END IF;
      END IF;

      IF vnumerr <> 0 THEN
         RETURN vnumerr;
      END IF;

      RETURN vnumerr;
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
   END f_controlduplicidad;

   FUNCTION f_set_conductor_tomador(
      pnriesgo IN NUMBER,
      pnorden IN NUMBER,
      psperson IN NUMBER,
      psproduc IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'parámetros - pnriesgo: ' || pnriesgo || ' pnorden:' || pnorden || ' psperson:'
            || psperson || ' psproduc:' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRODUCCION_AUT.f_set_conductor_tomador';
      num_err        NUMBER;
   BEGIN
      IF NVL(pac_mdpar_productos.f_get_parproducto('CONDUCTOR_TOMADOR', psproduc), 0) = 1 THEN
         num_err :=
            pac_md_produccion_aut.f_set_conductor(pnriesgo, pnorden, psperson, NULL, NULL,
                                                  NULL, NULL, NULL, 1,   -- Bug 31686/179563 - 11/07/2014 - AMC
                                                  NULL, NULL, NULL, NULL, mensajes);

         IF num_err <> 0 THEN
            vpasexec := 2;
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN num_err;
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
   END f_set_conductor_tomador;

    /*************************************************************************
      Recuperar informacion del primer asegurado que no es tomador
      param out mensajes : mensajes de error
      param in  pnriesgo : numero riesgo
      return             : objeto asegurados
   *************************************************************************/
   FUNCTION f_leeaseguradonotomador(
      mensajes OUT t_iax_mensajes,
      pnriesgo IN NUMBER DEFAULT 1,
      pntomador IN NUMBER)
      RETURN ob_iax_asegurados IS
      aseg           t_iax_asegurados;
      rie            ob_iax_riesgos;
      aux            NUMBER;
      num_err        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRODUCCION_AUT.F_LeeAseguradoNoTomador';
   BEGIN
      IF pntomador IS NULL THEN
         RETURN NULL;
      END IF;

      vpasexec := 2;

      IF pac_iax_produccion.poliza.det_poliza IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000644);
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      -- vigilar amb el 1 fitxe a riscos per asegurats acc
      --// ACC he canviat el 1 per un parametre d'entrada 25022008
      rie := pac_iobj_prod.f_partpolriesgo(pac_iax_produccion.poliza.det_poliza, pnriesgo,
                                           mensajes);

      IF rie IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001040);
         vpasexec := 4;
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      aseg := pac_iobj_prod.f_partriesasegurado(rie, mensajes);

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            vpasexec := 6;
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 7;

      IF aseg IS NULL THEN
         RETURN NULL;
      END IF;

      vpasexec := 8;

      IF aseg.COUNT = 0 THEN
         RETURN NULL;
      END IF;

      vpasexec := 9;

      IF aseg.COUNT = 1
         AND aseg(1).sperson = pntomador THEN
         RETURN NULL;
      END IF;

      vpasexec := 10;
      aux := aseg.FIRST;

      FOR idx IN aseg.FIRST .. aseg.LAST LOOP
         --si el asegurado no es tomador ni persona jurídica será el que retornemos
         IF aseg(idx).sperson <> pntomador
            AND aseg(idx).ctipper != 2 THEN
            aux := idx;
            EXIT;
         END IF;
      END LOOP;

      vpasexec := 11;
      num_err :=
         pac_md_persona.f_get_persona_agente(aseg(aux).sperson,
                                             pac_iax_produccion.poliza.det_poliza.cagente,
                                             pac_iax_produccion.vpmode, aseg(aux), mensajes);
      vpasexec := 12;

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            vpasexec := 13;
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN aseg(aux);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_leeaseguradonotomador;

   /*************************************************************************
      Recuperar informacion del primer asegurado que no es tomador
      param out mensajes : mensajes de error
      param in  pnriesgo : numero riesgo
      return             : objeto asegurados
   *************************************************************************/
   FUNCTION f_leeasegurados(mensajes OUT t_iax_mensajes, pnriesgo IN NUMBER DEFAULT 1)
      RETURN t_iax_asegurados IS
      aseg           t_iax_asegurados;
      rie            ob_iax_riesgos;
      num_err        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRODUCCION_AUT.F_LeeAsegurados';
   BEGIN
      vpasexec := 2;

      IF pac_iax_produccion.poliza.det_poliza IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000644);
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      -- vigilar amb el 1 fitxe a riscos per asegurats acc
      --// ACC he canviat el 1 per un parametre d'entrada 25022008
      rie := pac_iobj_prod.f_partpolriesgo(pac_iax_produccion.poliza.det_poliza, pnriesgo,
                                           mensajes);

      IF rie IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001040);
         vpasexec := 4;
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      aseg := pac_iobj_prod.f_partriesasegurado(rie, mensajes);

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            vpasexec := 6;
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 7;

      IF aseg IS NULL THEN
         RETURN NULL;
      END IF;

      vpasexec := 8;

      IF aseg.COUNT = 0 THEN
         RETURN NULL;
      END IF;

      vpasexec := 10;

      FOR idx IN aseg.FIRST .. aseg.LAST LOOP
         num_err :=
            pac_md_persona.f_get_persona_agente(aseg(idx).sperson,
                                                pac_iax_produccion.poliza.det_poliza.cagente,
                                                pac_iax_produccion.vpmode, aseg(idx),
                                                mensajes);
      END LOOP;

      RETURN aseg;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_leeasegurados;
END pac_iax_produccion_aut;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_PRODUCCION_AUT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PRODUCCION_AUT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PRODUCCION_AUT" TO "PROGRAMADORESCSI";
