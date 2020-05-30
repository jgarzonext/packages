--------------------------------------------------------
--  DDL for Package Body PAC_IOBJ_PROD
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY PAC_IOBJ_PROD AS
   /******************************************************************************
      NOMBRE:       PAC_IOBJ_PROD
      PROPÓSITO:  Funciones de tratamiento objetos produccion

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        25/01/2008   ACC                1. Creación del package.
      2.0        27/02/2009   RSC                2. Adaptación iAxis a productos colectivos con certificados
      3.0        11/03/2009   RSC                3. iAxis: Análisis adaptación productos indexados
      4.0        16/09/2009   AMC                4. 11165: Se sustituñe  T_iax_saldodeutorseg por t_iax_prestamoseg
      5.0        15/10/2009   DRA                5. 0010569: CRE080 - Suplementos/ Anulaciones para el producto Saldo Deutors
      6.0        17/05/2011   APD                6. 0018362: LCOL003 - Parámetros en cláusulas y visualización cláusulas automáticas
      7.0        26/07/2011   DRA                7. 0017255: CRT003 - Definir propuestas de suplementos en productos
      8.0        27/09/2011   DRA                8. 0019069: LCOL_C001 - Co-corretaje
      9.0        08/03/2012   JMF                0021592: MdP - TEC - Gestor de Cobro
     10.0        02/05/2011   MDS                10. 0021907: MDP - TEC - Descuentos y recargos (técnico y comercial) a nivel de póliza/riesgo/garantía
     11.0        04/06/2012   ETM                11. 0021657: MDP - TEC - Pantalla Inquilinos y Avalistas
     12.0        14/08/2012   DCG                12. 0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
     13.0        03/09/2012   JMF                0022701: LCOL: Implementación de Retorno
     14.0        18/02/2013   DRA                14. 0024804: (POSRA100)-Ramo:Rentas- Parametrizacion Conmutacion Pensional
     15.0        27/07/2015   IGIL               15. 0036596 MSV - get y set de type citas medicas
     16.0        07/03/2016   JAEG               16. 40927/228750: Desarrollo Diseño técnico CONF_TEC-03_CONTRAGARANTIAS
     17.0        26/06/2019   CJMR               17. IAXIS-4203: Configuración productos RCE
     18.0        21/01/2020   JLTS               18. IAXIS-10627. Se ajustó la función f_partpolcorretaje incluyendo el parámetro NMOVIMI
   ******************************************************************************/

   /*************************************************************************
   **
   ** Funciones para devolución de partes del objeto poliza
   **
   *************************************************************************/

   /*************************************************************************
      Recupera la poliza como objeto persistente
      param out mensajes : mensajes de error
      return             : objeto detalle póliza
   *************************************************************************/
   FUNCTION f_getpoliza(mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_detpoliza IS
      tmppoliza  ob_iax_poliza;
      tmpdpoliza ob_iax_detpoliza;
      vpasexec   NUMBER(8) := 1;
      vparam     VARCHAR2(1) := NULL;
      vobject    VARCHAR2(200) := 'PAC_IOBJ_PROD.F_GetPoliza';
   BEGIN
      IF pac_iax_produccion.poliza IS NOT NULL
      THEN
         tmppoliza := pac_iax_produccion.poliza;
         vpasexec  := 2;

         IF tmppoliza IS NOT NULL
         THEN
            tmpdpoliza := tmppoliza.det_poliza;
            vpasexec   := 3;
         ELSE
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes,
                                                 1,
                                                 4563,
                                                 'No se ha podido recuperar el objeto persistente');
            RETURN NULL;
         END IF;
      ELSE
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes,
                                              1,
                                              4568,
                                              'No se ha podido recuperar el objeto persistente');
         RETURN NULL;
      END IF;

      RETURN tmpdpoliza;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_getpoliza;

   /*************************************************************************
      Establece la poliza como objeto persistente
      param out mensajes : mensajes de error
   *************************************************************************/
   PROCEDURE p_set_poliza(detpoliza IN ob_iax_detpoliza) IS
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.P_Set_Poliza';
      msj      t_iax_mensajes := NULL;
   BEGIN
      pac_iax_produccion.poliza.det_poliza := detpoliza;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msj,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
   END p_set_poliza;

   /*************************************************************************
      Devuelve parte del objeto poliza a un objeto tomadores
      param in poliza       : objeto detalle póliza
      param in out mensajes : colección de mensajes
      return                : objeto colección tomadores
   *************************************************************************/
   FUNCTION f_partpoltomadores(poliza   IN ob_iax_detpoliza,
                               mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_tomadores IS
      tomador  t_iax_tomadores;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_PartPolTomadores';
   BEGIN
      IF poliza.tomadores IS NOT NULL
      THEN
         IF poliza.tomadores.count > 0
         THEN
            RETURN poliza.tomadores;
         END IF;
      END IF;

      tomador := t_iax_tomadores();
      RETURN tomador;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_partpoltomadores;

   /*************************************************************************
      Devuelve parte del objeto poliza a un objeto gestion
      param in poliza       : objeto detalle póliza
      param in out mensajes : colección de mensajes
      return                : objeto gestion
   *************************************************************************/
   FUNCTION f_partpoldatosgestion(poliza   IN ob_iax_detpoliza,
                                  mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_gestion IS
      gest     ob_iax_gestion;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_PartPolDatosGestion';
   BEGIN
      IF poliza.gestion IS NOT NULL
      THEN
         RETURN poliza.gestion;
      END IF;

      gest := ob_iax_gestion();
      RETURN gest;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_partpoldatosgestion;

   /*************************************************************************
      Devuelve parte del objeto poliza a un objeto preguntas poliza
      param in poliza       : objeto detalle póliza
      param in out mensajes : colección de mensajes
      return                : objeto preguntas
   *************************************************************************/
   FUNCTION f_partpolpreguntas(poliza   IN ob_iax_detpoliza,
                               mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_preguntas IS
      preg     t_iax_preguntas;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_PartPolPreguntas';
   BEGIN
      IF poliza.preguntas IS NOT NULL
      THEN
         RETURN poliza.preguntas;
      END IF;

      RETURN preg;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_partpolpreguntas;

   /*************************************************************************
      Devuelve parte del objeto poliza a un objeto riesgos
      param in poliza       : objeto detalle póliza
      param in out mensajes : colección de mensajes
      return                : objeto colección riesgos
   *************************************************************************/
   FUNCTION f_partpolriesgos(poliza   IN ob_iax_detpoliza,
                             mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_riesgos IS
      riesgos  t_iax_riesgos;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_PartPolRiesgos';
   BEGIN
      IF poliza.riesgos IS NOT NULL
      THEN
         IF poliza.riesgos.count > 0
         THEN
            RETURN poliza.riesgos;
         END IF;
      END IF;

      riesgos := t_iax_riesgos();
      RETURN riesgos;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_partpolriesgos;

   -- JLTS
   /*************************************************************************
      Devuelve parte del objeto poliza a un objeto agenda
      param in poliza       : objeto detalle pÃ³liza
      param in out mensajes : colecciÃ³n de mensajes
      return                : objeto colecciÃ³n agenda
   *************************************************************************/
   FUNCTION f_partpolagensegu(poliza   IN ob_iax_detpoliza,
                              mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_agensegu IS
      agenda   t_iax_agensegu;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.f_partpolagendas';
   BEGIN
      IF poliza.agensegu IS NOT NULL
      THEN
         IF poliza.agensegu.count > 0
         THEN
            RETURN poliza.agensegu;
         END IF;
      END IF;

      agenda := t_iax_agensegu();
      RETURN agenda;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                           vpasexec, vparam,
                                           psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         RETURN NULL;
   END f_partpolagensegu;
   -- JLTS

   /*************************************************************************
      Devuelve parte del objeto poliza a un objeto riesgo
      param in poliza       : objeto detalle póliza
      param in out mensajes : colección de mensajes
      return                : objeto riesgos
   *************************************************************************/
   FUNCTION f_partpolriesgo(poliza   IN ob_iax_detpoliza,
                            pnriesgo IN NUMBER,
                            mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_riesgos IS
      riesgo   ob_iax_riesgos;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_PartPolRiesgo';
   BEGIN
      IF poliza.riesgos IS NOT NULL
      THEN
         IF poliza.riesgos.count > 0
         THEN
            vpasexec := 2;

            FOR i IN poliza.riesgos.first .. poliza.riesgos.last
            LOOP
               vpasexec := 3;

               IF poliza.riesgos.exists(i)
               THEN
                  vpasexec := 4;

                  IF poliza.riesgos(i).nriesgo = pnriesgo
                  THEN
                     vpasexec := 5;
                     RETURN poliza.riesgos(i);
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      riesgo := ob_iax_riesgos();
      RETURN riesgo;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_partpolriesgo;

   /*************************************************************************
      Devuelve parte del objeto poliza a un objeto clausulas
      param in poliza       : objeto detalle póliza
      param in out mensajes : colección de mensajes
      return                : objeto colección clausulas
   *************************************************************************/
   FUNCTION f_partpolclausulas(poliza   IN ob_iax_detpoliza,
                               mensajes IN OUT t_iax_mensajes,
                               pmode    IN VARCHAR2 DEFAULT 'EST') -- Bug 18362 - APD - 01/06/2011
    RETURN t_iax_clausulas IS
      clau     t_iax_clausulas;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_PartPolClausulas';
      vnumerr  NUMBER;
      vpoliza  ob_iax_detpoliza;
   BEGIN
      -- Bug 18362 - APD - 17/05/2001 - se insertan las clausulas automàticas de
      -- garantias / preguntas al objecte de ob_iax_clausulas
      -- se sustituye el parametro poliza por vpoliza para poder añadirle las
      -- clausulas automaticas de garantias / preguntas
      vpoliza := poliza;

      IF pmode <> 'POL'
      THEN
         -- BUG 21546_108727- 23/02/2012 - JLTS - Se quita la utilizacion del objeto mensajes
         vnumerr := pac_clausulas.f_ins_clauobj(vpoliza);

         IF vnumerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         END IF;
      END IF;

      -- Bug 18362 - APD - 17/05/2001 - se sustituye el poliza por vpoliza
      IF vpoliza.clausulas IS NOT NULL
      THEN
         IF vpoliza.clausulas.count > 0
         THEN
            RETURN vpoliza.clausulas;
         END IF;
      END IF;

      -- fin Bug 18362 - APD - 17/05/2001
      clau := t_iax_clausulas();
      RETURN clau;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_partpolclausulas;

   /*************************************************************************
      Devuelve parte del objeto poliza a un objeto primas
      param in poliza       : objeto detalle póliza
      param in out mensajes : colección de mensajes
      return                : objeto colección primas
   *************************************************************************/
   FUNCTION f_partpolprimas(poliza   IN ob_iax_detpoliza,
                            mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_primas IS
      primas   t_iax_primas;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_PartPolPrimas';
   BEGIN
      IF poliza.primas IS NOT NULL
      THEN
         IF poliza.primas.count > 0
         THEN
            RETURN poliza.primas;
         END IF;
      END IF;

      primas := t_iax_primas();
      RETURN primas;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_partpolprimas;

   /*************************************************************************
      Devuelve parte del objeto poliza a un objeto comisiones
      param in poliza       : objeto detalle póliza
      param in out mensajes : colección de mensajes
      return                : objeto colección de comisiones
   *************************************************************************/
   FUNCTION f_partpolcomisiones(poliza   IN ob_iax_detpoliza,
                                mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_gstcomision IS
      gstcom   t_iax_gstcomision;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_PartPolComisiones';
   BEGIN
      IF poliza.gstcomision IS NOT NULL
      THEN
         IF poliza.gstcomision.count > 0
         THEN
            RETURN poliza.gstcomision;
         END IF;
      END IF;

      RETURN gstcom;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_partpolcomisiones;

   /*************************************************************************
      Devuelve parte del objeto riesgo a un objeto riespersonal
      param in poliza       : objeto riesgo
      param in out mensajes : colección de mensajes
      return                : objeto colección personas
   *************************************************************************/
   FUNCTION f_partriespersonal(riesgo   IN ob_iax_riesgos,
                               mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_personas IS
      rperson  t_iax_personas;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_PartRiesPersonal';
   BEGIN
      IF riesgo IS NOT NULL
      THEN
         RETURN riesgo.riespersonal;
      END IF;

      rperson := t_iax_personas();
      RETURN rperson;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_partriespersonal;

   /*************************************************************************
      Devuelve parte del objeto riesgo a un objeto riesdirecciones
      param in poliza       : objeto riesgo
      param in out mensajes : colección de mensajes
      return                : objeto colección de direcciones
   *************************************************************************/
   FUNCTION f_partriesdirecciones(riesgo   IN ob_iax_riesgos,
                                  mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_sitriesgos IS
      direc    ob_iax_sitriesgos;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_PartRiesDirecciones';
   BEGIN
      IF riesgo IS NOT NULL
      THEN
         IF riesgo.riesdireccion IS NOT NULL
         THEN
            --IF riesgo.riesdireccion.count > 0 THEN
            RETURN riesgo.riesdireccion;
            --END IF;
         END IF;
      END IF;

      direc := ob_iax_sitriesgos();
      RETURN direc;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_partriesdirecciones;

   /*************************************************************************
      Devuelve parte del objeto riesgo a un objeto riesgoase
      param in poliza       : objeto riesgo
      param in out mensajes : colección de mensajes
      return                : objeto colección asegurados
   *************************************************************************/
   FUNCTION f_partriesasegurado(riesgo   IN ob_iax_riesgos,
                                mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_asegurados IS
      aseg     t_iax_asegurados;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_PartRiesAsegurado';
   BEGIN
      IF riesgo IS NOT NULL
      THEN
         IF riesgo.riesgoase IS NOT NULL
         THEN
            IF riesgo.riesgoase.count > 0
            THEN
               RETURN riesgo.riesgoase;
            END IF;
         END IF;
      END IF;

      aseg := t_iax_asegurados();
      RETURN aseg;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_partriesasegurado;

   /*************************************************************************
      Devuelve parte del objeto riesgo a un objeto preguntas
      param in poliza       : objeto riesgo
      param in out mensajes : colección de mensajes
      return                : objeto colección preguntas
   *************************************************************************/
   FUNCTION f_partriespreguntas(riesgo   IN ob_iax_riesgos,
                                mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_preguntas IS
      preg     t_iax_preguntas;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_PartRiesPreguntas';
   BEGIN
      IF riesgo IS NOT NULL
      THEN
         IF riesgo.preguntas IS NOT NULL
         THEN
            IF riesgo.preguntas.count > 0
            THEN
               RETURN riesgo.preguntas;
            END IF;
         END IF;
      END IF;

      preg := t_iax_preguntas();
      RETURN preg;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_partriespreguntas;

   /*************************************************************************
      Devuelve parte del objeto riesgo a un objeto garantias
      param in poliza       : objeto riesgo
      param in out mensajes : colección de mensajes
      return                : objeto colección garantias
   *************************************************************************/
   FUNCTION f_partriesgarantias(riesgo   IN ob_iax_riesgos,
                                mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_garantias IS
      garant   t_iax_garantias;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_PartRiesGarantias';
   BEGIN
      IF riesgo IS NOT NULL
      THEN
         IF riesgo.garantias IS NOT NULL
         THEN
            IF riesgo.garantias.count > 0
            THEN
               RETURN riesgo.garantias;
            END IF;
         END IF;
      END IF;

      garant := t_iax_garantias();
      RETURN garant;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_partriesgarantias;

   /*************************************************************************
      Devuelve parte del objeto riesgo a un objeto garantia
      param in poliza       : objeto riesgo
      param in cgarant      : código de garantia
      param in out mensajes : colección de mensajes
      return                : objeto garantia
   *************************************************************************/
   FUNCTION f_partriesgarantia(riesgo   IN ob_iax_riesgos,
                               cgarant  IN NUMBER,
                               mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_garantias IS
      garant   ob_iax_garantias;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_PartRiesGarantia';
   BEGIN
      IF riesgo IS NOT NULL
      THEN
         IF riesgo.garantias IS NOT NULL
         THEN
            vpasexec := 2;

            IF riesgo.garantias.count > 0
            THEN
               vpasexec := 3;

               FOR i IN riesgo.garantias.first .. riesgo.garantias.last
               LOOP
                  vpasexec := 4;

                  IF riesgo.garantias.exists(i)
                  THEN
                     vpasexec := 5;

                     IF riesgo.garantias(i).cgarant = cgarant
                     THEN
                        RETURN riesgo.garantias(i);
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         END IF;
      END IF;

      garant := ob_iax_garantias();
      RETURN garant;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_partriesgarantia;

   /*************************************************************************
      Devuelve parte del objeto riesgo a un objeto beneficiarios
      param in poliza       : objeto riesgo
      param in out mensajes : colección de mensajes
      return                : objeto beneficiario
   *************************************************************************/
   FUNCTION f_partriesbeneficiarios(riesgo   IN ob_iax_riesgos,
                                    mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_beneficiarios IS
      bene     ob_iax_beneficiarios;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_PartRiesBeneficiarios';
   BEGIN
      IF riesgo IS NOT NULL
      THEN
         IF riesgo.beneficiario IS NOT NULL
         THEN
            RETURN riesgo.beneficiario;
         END IF;
      END IF;

      bene := ob_iax_beneficiarios();
      RETURN bene;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_partriesbeneficiarios;

   /*************************************************************************
      Devuelve parte del objeto riesgo a un objeto beneficiarios nominales
      param in poliza       : objeto riesgo
      param in out mensajes : colección de mensajes
      return                : objeto colección beneficiarios nominales
   *************************************************************************/
   FUNCTION f_partriesbenenominales(riesgo   IN ob_iax_riesgos,
                                    mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_benenominales IS
      bene     t_iax_benenominales;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_PartRiesBeneNominales';
   BEGIN
      IF riesgo IS NOT NULL
      THEN
         IF riesgo.beneficiario IS NOT NULL
         THEN
            vpasexec := 2;

            IF riesgo.beneficiario.nominales IS NOT NULL
            THEN
               vpasexec := 3;
               RETURN riesgo.beneficiario.nominales;
            END IF;
         END IF;
      END IF;

      bene := t_iax_benenominales();
      RETURN bene;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_partriesbenenominales;

   /*************************************************************************
      Devuelve parte del objeto garantias a un objeto preguntas
      param in poliza       : objeto garantia
      param in out mensajes : colección de mensajes
      return                : objeto colección preguntas
   *************************************************************************/
   FUNCTION f_partgarpreguntas(garantia IN ob_iax_garantias,
                               mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_preguntas IS
      preg     t_iax_preguntas;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_PartGarPreguntas';
   BEGIN
      IF garantia IS NOT NULL
      THEN
         IF garantia.preguntas IS NOT NULL
         THEN
            IF garantia.preguntas.count > 0
            THEN
               RETURN garantia.preguntas;
            END IF;
         END IF;
      END IF;

      preg := t_iax_preguntas();
      RETURN preg;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_partgarpreguntas;

   /*************************************************************************
      Devuelve parte del objeto automovil a un objeto conductores
      param in poliza       : objeto automovil
      param in out mensajes : colección de mensajes
      return                : objeto colección conductores
   *************************************************************************/
   FUNCTION f_partautconductores(autos    IN ob_iax_autriesgos,
                                 mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_autconductores IS
      cond     t_iax_autconductores;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_PartAutConductores';
   BEGIN
      IF autos IS NOT NULL
      THEN
         IF autos.conductores IS NOT NULL
         THEN
            vpasexec := 2;

            IF autos.conductores.count > 0
            THEN
               vpasexec := 3;
               RETURN autos.conductores;
            END IF;
         END IF;
      END IF;

      cond := t_iax_autconductores();
      RETURN cond;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN cond;
   END f_partautconductores;

   /*************************************************************************
      Devuelve parte del objeto automovil a un objeto accesorios
      param in poliza       : objeto automovil
      param in out mensajes : colección de mensajes
      return                : objeto colección accesorios
   *************************************************************************/
   FUNCTION f_partautaccesorios(autos    IN ob_iax_autriesgos,
                                mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_autaccesorios IS
      accs     t_iax_autaccesorios;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_PartAutAccesorios';
   BEGIN
      IF autos IS NOT NULL
      THEN
         IF autos.accesorios IS NOT NULL
         THEN
            vpasexec := 2;

            IF autos.accesorios.count > 0
            THEN
               vpasexec := 3;
               RETURN autos.accesorios;
            END IF;
         END IF;
      END IF;

      accs := t_iax_autaccesorios();
      RETURN accs;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_partautaccesorios;

   --JRH 03/2008
   /*************************************************************************
      Devuelve parte del objeto aqsociado a rentas irregulares
      param in riesgo       : objeto riesgo
      param in out mensajes : colección de mensajes
      return                : objeto colección rentas irregulares del riesgo
   *************************************************************************/
   FUNCTION f_partrentirreg(riesgo   IN ob_iax_riesgos,
                            mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_rentairr IS
      irreg    t_iax_rentairr;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_PartRentIrreg';
   BEGIN
      IF riesgo IS NOT NULL
      THEN
         IF riesgo.rentirreg IS NOT NULL
         THEN
            IF riesgo.rentirreg.count > 0
            THEN
               RETURN riesgo.rentirreg;
            END IF;
         END IF;
      END IF;

      irreg := t_iax_rentairr();
      RETURN irreg;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_partrentirreg;

   --JRH 03/2008

   --JRH 03/2008
   /*************************************************************************
      Sustituye el objeto renta irregular del riesgo determinado
      param in poliza       : objeto riesgo
      param in nriesgo      : número de riesgo
      param in irreg         : objeto rentas irregulares
      param in out mensajes : colección de mensajes
      return                : objeto colección preguntas
   *************************************************************************/
   FUNCTION f_set_partriesrentirreg(poliza   IN OUT ob_iax_detpoliza,
                                    nriesgo  IN riesgos.nriesgo%TYPE,
                                    irreg    IN t_iax_rentairr,
                                    mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      riesgo   ob_iax_riesgos;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_Set_PartriesRentIrreg';
   BEGIN
      IF poliza.riesgos IS NOT NULL
      THEN
         IF poliza.riesgos.count > 0
         THEN
            vpasexec := 2;

            FOR i IN poliza.riesgos.first .. poliza.riesgos.last
            LOOP
               vpasexec := 3;

               IF poliza.riesgos.exists(i)
               THEN
                  vpasexec := 5;

                  IF poliza.riesgos(i).nriesgo = nriesgo
                  THEN
                     vpasexec := 6;
                     poliza.riesgos(i).rentirreg := irreg;
                     RETURN 0;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000646);
      RETURN 1;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_set_partriesrentirreg;

   --JRH 03/2008

   /***********************************************************************/

   /*************************************************************************
   **
   ** Funciones para incluir partes del objeto poliza
   **
   *************************************************************************/

   /*************************************************************************
      Sustituye el objeto tomadores
      param in poliza       : objeto riesgo
      param in tom          : objeto tomadores
      param in out mensajes : colección de mensajes
      return                : 0 todo correcto
                              1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_parttomadores(poliza   IN OUT ob_iax_detpoliza,
                                tom      IN t_iax_tomadores,
                                mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_Set_PartTomadores';
   BEGIN
      poliza.tomadores := tom;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_set_parttomadores;

   /*************************************************************************
      Sustituye el objeto gestor cobro
      param in poliza       : objeto poliza
      param in tom          : objeto gestor cobro
      param in out mensajes : colección de mensajes
      return                : 0 todo correcto
                              1 ha habido un error
   *************************************************************************/
   -- Bug 0021592 - 08/03/2012 - JMF
   FUNCTION f_set_partgestorcobro(poliza   IN OUT ob_iax_detpoliza,
                                  gesc     IN t_iax_gescobros,
                                  mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_Set_partgestorcobro';
   BEGIN
      poliza.gestorcobro := gesc;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_set_partgestorcobro;

   /*************************************************************************
      Sustituye el objeto riesgos del riesgo determinado
      param in poliza       : objeto riesgo
      param in nriesgo      : número de riesgo
      param in riesgo       : objeto riesgo
      param in out mensajes : colección de mensajes
      return                : 0 todo correcto
                              1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_partriesgo(poliza   IN OUT ob_iax_detpoliza,
                             nriesgo  IN NUMBER,
                             riesgo   IN ob_iax_riesgos,
                             mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_Set_PartRiesgo';
   BEGIN
      IF poliza.riesgos IS NOT NULL
      THEN
         vpasexec := 2;

         IF poliza.riesgos.count > 0
         THEN
            vpasexec := 3;

            FOR i IN poliza.riesgos.first .. poliza.riesgos.last
            LOOP
               vpasexec := 4;

               IF poliza.riesgos.exists(i)
               THEN
                  vpasexec := 5;

                  IF poliza.riesgos(i).nriesgo = nriesgo
                  THEN
                     vpasexec := 6;
                     poliza.riesgos(i) := riesgo;
                     RETURN 0;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000646);
      RETURN 1;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_set_partriesgo;

   /*************************************************************************
      Sustituye el objeto beneficiario del riesgo determinado
      param in poliza       : objeto riesgo
      param in nriesgo      : número de riesgo
      param in bene         : objeto beneficiario
      param in out mensajes : colección de mensajes
      return                : objeto colección preguntas
   *************************************************************************/
   FUNCTION f_set_partriesbeneficiarios(poliza   IN OUT ob_iax_detpoliza,
                                        nriesgo  IN NUMBER,
                                        bene     IN ob_iax_beneficiarios,
                                        mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      riesgo   ob_iax_riesgos;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_Set_PartRiesBeneficiarios';
   BEGIN
      IF poliza.riesgos IS NOT NULL
      THEN
         IF poliza.riesgos.count > 0
         THEN
            vpasexec := 2;

            FOR i IN poliza.riesgos.first .. poliza.riesgos.last
            LOOP
               vpasexec := 3;

               IF poliza.riesgos.exists(i)
               THEN
                  vpasexec := 5;

                  IF poliza.riesgos(i).nriesgo = nriesgo
                  THEN
                     vpasexec := 6;
                     poliza.riesgos(i).beneficiario := bene;
                     RETURN 0;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000646);
      RETURN 1;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_set_partriesbeneficiarios;

   /*************************************************************************
      Sustituye el objeto preguntas del riesgo determinado
      param in poliza       : objeto riesgo
      param in nriesgo      : número de riesgo
      param in preg         : objeto preguntas
      param in out mensajes : colección de mensajes
      return                : objeto colección preguntas
   *************************************************************************/
   FUNCTION f_set_partriespreguntas(poliza   IN OUT ob_iax_detpoliza,
                                    nriesgo  IN NUMBER,
                                    preg     IN t_iax_preguntas,
                                    mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_Set_PartRiesPreguntas';
   BEGIN
      IF poliza.riesgos IS NOT NULL
      THEN
         IF poliza.riesgos.count > 0
         THEN
            vpasexec := 2;

            FOR i IN poliza.riesgos.first .. poliza.riesgos.last
            LOOP
               vpasexec := 3;

               IF poliza.riesgos.exists(i)
               THEN
                  vpasexec := 4;

                  IF poliza.riesgos(i).nriesgo = nriesgo
                  THEN
                     vpasexec := 5;
                     poliza.riesgos(i).preguntas := preg;
                     RETURN 0;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000646);
      RETURN 1;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_set_partriespreguntas;

   /*************************************************************************
      Sustituye el objeto garantias del riesgo determinado
      param in poliza       : objeto riesgo
      param in nriesgo      : número de riesgo
      param in gar          : objeto garantias
      param in out mensajes : colección de mensajes
      return                : objeto colección preguntas
   *************************************************************************/
   FUNCTION f_set_partriesgarantias(poliza   IN OUT ob_iax_detpoliza,
                                    nriesgo  IN NUMBER,
                                    gar      IN t_iax_garantias,
                                    mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_Set_PartRiesGarantias';
   BEGIN
      IF poliza.riesgos IS NOT NULL
      THEN
         vpasexec := 2;

         IF poliza.riesgos.count > 0
         THEN
            vpasexec := 3;

            FOR i IN poliza.riesgos.first .. poliza.riesgos.last
            LOOP
               vpasexec := 4;

               IF poliza.riesgos.exists(i)
               THEN
                  vpasexec := 5;

                  IF poliza.riesgos(i).nriesgo = nriesgo
                  THEN
                     vpasexec := 6;
                     poliza.riesgos(i).garantias := gar;
                     RETURN 0;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000646);
      RETURN 1;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_set_partriesgarantias;

   /*************************************************************************
      Sustituye el objeto garantia del riesgo determinado de la lista garantias
      param in poliza       : objeto riesgo
      param in nriesgo      : número de riesgo
      param in gar          : objeto garantia
      param in out mensajes : colección de mensajes
      return                : 0 todo correcto
                              1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_partriesgarantia(poliza   IN OUT ob_iax_detpoliza,
                                   nriesgo  IN NUMBER,
                                   gar      IN ob_iax_garantias,
                                   mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_Set_PartRiesGarantia';
   BEGIN
      IF poliza.riesgos IS NOT NULL
      THEN
         vpasexec := 2;

         IF poliza.riesgos.count > 0
         THEN
            vpasexec := 3;

            FOR i IN poliza.riesgos.first .. poliza.riesgos.last
            LOOP
               vpasexec := 4;

               IF poliza.riesgos.exists(i)
               THEN
                  vpasexec := 5;

                  IF poliza.riesgos(i).nriesgo = nriesgo
                  THEN
                     vpasexec := 6;

                     IF poliza.riesgos(i).garantias IS NOT NULL
                     THEN
                        vpasexec := 7;

                        IF poliza.riesgos(i).garantias.count > 0
                        THEN
                           vpasexec := 8;

                           FOR gr IN poliza.riesgos(i).garantias.first .. poliza.riesgos(i)
                                                                          .garantias.last
                           LOOP
                              vpasexec := 9;

                              IF poliza.riesgos(i).garantias.exists(gr)
                              THEN
                                 vpasexec := 10;

                                 IF poliza.riesgos(i).garantias(gr)
                                  .cgarant = gar.cgarant
                                 THEN
                                    vpasexec := 11;
                                    poliza.riesgos(i).garantias(gr) := gar;
                                    RETURN 0;
                                 END IF;
                              END IF;
                           END LOOP;
                        END IF;
                     END IF;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000646);
      RETURN 1;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_set_partriesgarantia;

   /*************************************************************************
      Sustituye del objeto garantias del riesgo las preguntas
      param in poliza       : objeto riesgo
      param in nriesgo      : número de riesgo
      param in cgarant      : código de garantia
      param in gar          : objeto garantias
      param in out mensajes : colección de mensajes
      return                : 0 todo correcto
                              1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_partgarpreguntas(poliza   IN OUT ob_iax_detpoliza,
                                   nriesgo  IN NUMBER,
                                   cgarant  IN NUMBER,
                                   pre      IN t_iax_preguntas,
                                   mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_Set_PartGarPreguntas';
   BEGIN
      IF poliza.riesgos IS NOT NULL
      THEN
         vpasexec := 2;

         IF poliza.riesgos.count > 0
         THEN
            vpasexec := 3;

            FOR i IN poliza.riesgos.first .. poliza.riesgos.last
            LOOP
               vpasexec := 4;

               IF poliza.riesgos.exists(i)
               THEN
                  vpasexec := 5;

                  IF poliza.riesgos(i).nriesgo = nriesgo
                  THEN
                     vpasexec := 6;

                     FOR x IN poliza.riesgos(i).garantias.first .. poliza.riesgos(i)
                                                                   .garantias.last
                     LOOP
                        vpasexec := 7;

                        IF poliza.riesgos(i).garantias.exists(x)
                        THEN
                           vpasexec := 8;

                           IF poliza.riesgos(i).garantias(x)
                            .cgarant = cgarant
                           THEN
                              vpasexec := 9;
                              poliza.riesgos(i).garantias(x).preguntas := pre;
                              RETURN 0;
                           END IF;
                        END IF;
                     END LOOP;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000646);
      RETURN 1;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_set_partgarpreguntas;

   /*************************************************************************
      Sustituye del objeto gestion
      param in poliza       : objeto riesgo
      param in gest         : objeto gestión
      param in out mensajes : colección de mensajes
      return                : 0 todo correcto
                              1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_partpoldatosgestion(poliza   IN OUT ob_iax_detpoliza,
                                      gest     IN ob_iax_gestion,
                                      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_Set_Partpoldatosgestion';
   BEGIN
      poliza.gestion := gest;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_set_partpoldatosgestion;

   /*************************************************************************
      Devuelve la información del objeto tipo descripción
      param in riesgo        : objeto riesgo
      param in out mensajes  : colección de mensajes
      return                 : objeto descripcion
   *************************************************************************/
   FUNCTION f_partriesdescripcion(riesgo   IN ob_iax_riesgos,
                                  mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_descripcion IS
      descr    ob_iax_descripcion;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_PartRiesDescripcion';
   BEGIN
      IF riesgo IS NOT NULL
      THEN
         IF riesgo.riesdescripcion IS NOT NULL
         THEN
            --IF riesgo.riesdescripcion.count > 0 then
            RETURN riesgo.riesdescripcion;
            --END IF;
         END IF;
      END IF;

      descr := ob_iax_descripcion();
      RETURN descr;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_partriesdescripcion;

   /***********************************************************************/
   /***********************************************************************
      Función que asigna el número de póliza del tomador del colectivo, al certificado que se crea nuevo,
      modificando una de las variables del tipo persistente de la contratación.
      param in pnpoliza  : número de póliza
      param in/out poliza  : número de póliza
      param out mensajes : mensajes de error
      return             : number  0 -> Ok  1 --> Error
   ***********************************************************************/
   -- Bug 8745 - 27/02/2009 - RSC - Adaptación iAxis a productos colectivos con certificados
   FUNCTION f_set_npoliza(pnpoliza IN NUMBER,
                          poliza   IN OUT ob_iax_detpoliza,
                          mensajes OUT t_iax_mensajes) RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(200) := 'pnpoliza = ' || pnpoliza;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.f_set_npoliza';
   BEGIN
      poliza.npoliza := pnpoliza;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_set_npoliza;

   /*************************************************************************
      Devuelve parte del objeto poliza a un objeto distribución poliza
      param in poliza       : objeto detalle póliza
      param in out mensajes : colección de mensajes
      return                : objeto distribución
   *************************************************************************/
   -- Bug 9031 - 11/03/2009 - RSC - iAxis: Análisis adaptación productos indexados
   FUNCTION f_partpolmodeloinv(poliza   IN ob_iax_detpoliza,
                               mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_produlkmodelosinv IS
      distr    ob_iax_produlkmodelosinv;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_PartPolModeloinv';
   BEGIN
      IF poliza.modeloinv IS NOT NULL
      THEN
         RETURN poliza.modeloinv;
      END IF;

      distr := ob_iax_produlkmodelosinv();
      RETURN distr;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_partpolmodeloinv;

   FUNCTION f_partriesautomoviles(riesgo   IN ob_iax_riesgos,
                                  mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_autriesgos IS
      autriesg ob_iax_autriesgos;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_PartRiesAutomoviles';
   BEGIN
      IF riesgo IS NOT NULL
      THEN
         IF riesgo.riesautos IS NOT NULL AND
            riesgo.riesautos.count > 0
         THEN
            vpasexec := 2;
            RETURN riesgo.riesautos(riesgo.riesautos.last);
         END IF;
      END IF;

      autriesg := ob_iax_autriesgos();
      RETURN autriesg;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_partriesautomoviles;

   /***********************************************************************/

   /*************************************************************************
   BUG 9247-24022009-XVM
   FUNCTION f_partriesautomovil
      Funció que retorna l'objecte OB_IAX_AUTRIESGOS amb tota la seva informació
      per a un risc en concret
       param in poliza       : objeto detalle póliza
       param in pnriesgo     : número risc
       param in out mensajes : missatges
       return                : objecte OB_IAX_AUTRIESGOS
   *************************************************************************/
   FUNCTION f_partriesautomovil(poliza   IN ob_iax_detpoliza,
                                pnriesgo IN NUMBER,
                                mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_autriesgos IS
      autorie  ob_iax_autriesgos;
      tautorie t_iax_autriesgos;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.f_partriesautomovil';
   BEGIN
      IF poliza IS NOT NULL
      THEN
         IF poliza.riesgos IS NOT NULL
         THEN
            IF poliza.riesgos.count > 0
            THEN
               vpasexec := 2;

               FOR i IN poliza.riesgos.first .. poliza.riesgos.last
               LOOP
                  vpasexec := 3;

                  IF poliza.riesgos.exists(i)
                  THEN
                     vpasexec := 4;

                     IF poliza.riesgos(i).nriesgo = pnriesgo
                     THEN
                        vpasexec := 5;

                        IF poliza.riesgos(i).riesautos.exists(1)
                        THEN
                           RETURN poliza.riesgos(i).riesautos(poliza.riesgos(i)
                                                              .riesautos.last);
                        END IF;
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         END IF;
      ELSE
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001116); --,'No se ha podido recuperar el objeto persistente');
         RETURN NULL;
      END IF;

      autorie := ob_iax_autriesgos();
      RETURN autorie;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_partriesautomovil;

   -- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_set_partautconductores
   /*************************************************************************
      Sustituye el objeto conductores del riesgo determinado
      param in poliza       : objeto poliza
      param in nriesgo      : número de riesgo
      param in cond         : objeto autconductores
      param in out mensajes : colección de mensajes
      return                : 0 todo correcto
                              1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_partautconductores(poliza   IN OUT ob_iax_detpoliza,
                                     pnriesgo IN NUMBER,
                                     pnorden  IN NUMBER,
                                     cond     IN ob_iax_autconductores,
                                     mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(100) := 'pnriesgo=' || pnriesgo || ', pnorden=' ||
                                pnorden;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_Set_partautconductores';
      vtrobat  BOOLEAN := TRUE;
   BEGIN
      IF poliza.riesgos IS NOT NULL
      THEN
         IF poliza.riesgos.count > 0
         THEN
            vpasexec := 2;

            FOR i IN poliza.riesgos.first .. poliza.riesgos.last
            LOOP
               vpasexec := 3;

               IF poliza.riesgos.exists(i)
               THEN
                  vpasexec := 4;

                  IF poliza.riesgos(i).nriesgo = pnriesgo
                  THEN
                     vpasexec := 5;

                     IF poliza.riesgos(i)
                      .riesautos.exists(poliza.riesgos(i).riesautos.last)
                     THEN
                        vpasexec := 6;

                        IF poliza.riesgos(i).riesautos(poliza.riesgos(i).riesautos.last)
                         .conductores IS NOT NULL
                        THEN
                           vpasexec := 7;

                           IF poliza.riesgos(i).riesautos(poliza.riesgos(i).riesautos.last)
                            .conductores.count > 0
                           THEN
                              vpasexec := 8;

                              FOR j IN poliza.riesgos(i).riesautos(poliza.riesgos(i).riesautos.last)
                                       .conductores.first .. poliza.riesgos(i).riesautos(poliza.riesgos(i).riesautos.last)
                                                             .conductores.last
                              LOOP
                                 IF poliza.riesgos(i).riesautos(poliza.riesgos(i).riesautos.last)
                                  .conductores.exists(j)
                                 THEN
                                    IF poliza.riesgos(i).riesautos(poliza.riesgos(i).riesautos.last).conductores(j)
                                     .norden = pnorden
                                    THEN
                                       vpasexec := 9;
                                       poliza.riesgos(i).riesautos(poliza.riesgos(i).riesautos.last).conductores(j) := cond;
                                       RETURN 0;
                                    END IF;
                                 END IF;
                              END LOOP;

                              -- No se modifica un registro, sino se dá de alta un nuevo registro en la coleccion ya existente
                              vpasexec := 10;
                              poliza.riesgos(i).riesautos(poliza.riesgos(i)
                                                          .riesautos.last).conductores.extend;
                              poliza.riesgos(i).riesautos(poliza.riesgos(i).riesautos.last).conductores(poliza.riesgos(i).riesautos(poliza.riesgos(i).riesautos.last).conductores.last) := ob_iax_autconductores();
                              poliza.riesgos(i).riesautos(poliza.riesgos(i).riesautos.last).conductores(poliza.riesgos(i).riesautos(poliza.riesgos(i).riesautos.last).conductores.last) := cond;
                              RETURN 0;
                           ELSE
                              vtrobat := FALSE;
                           END IF;
                        ELSE
                           vtrobat := FALSE;
                        END IF;

                        -- BUG17255:DRA:26/07/2011:Inici
                        IF NOT vtrobat
                        THEN
                           -- Se dá de alta el primer registro en la coleccion que está vacía (por lo que se tiene que inicializar)
                           poliza.riesgos(i).riesautos(poliza.riesgos(i).riesautos.last).conductores := t_iax_autconductores();
                           poliza.riesgos(i).riesautos(poliza.riesgos(i)
                                                       .riesautos.last).conductores.extend;
                           poliza.riesgos(i).riesautos(poliza.riesgos(i).riesautos.last).conductores(poliza.riesgos(i).riesautos(poliza.riesgos(i).riesautos.last).conductores.last) := ob_iax_autconductores();
                           poliza.riesgos(i).riesautos(poliza.riesgos(i).riesautos.last).conductores(poliza.riesgos(i).riesautos(poliza.riesgos(i).riesautos.last).conductores.last) := cond;
                           RETURN 0;
                        END IF;
                        -- BUG17255:DRA:26/07/2011:Fi
                     END IF;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000646);
      RETURN 1;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_set_partautconductores;

   -- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_set_partautconductores

   -- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_set_partriesautomovil
   /*************************************************************************
   FUNCTION f_set_partriesautomovil
       Sustituye el objeto autriesgos del riesgo determinado
       param in poliza       : objeto detalle póliza
       param in pnriesgo     : número risc
       param in autries     : lista de objetos autriesgos
       param in out mensajes : missatges
       return                : 0 todo correcto
                               1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_partriesautomovil(poliza   IN OUT ob_iax_detpoliza,
                                    pnriesgo IN NUMBER,
                                    ries     IN ob_iax_riesgos,
                                    autries  IN ob_iax_autriesgos,
                                    mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.f_set_partriesautomovil';
   BEGIN
      IF poliza.riesgos IS NOT NULL
      THEN
         IF poliza.riesgos.count > 0
         THEN
            vpasexec := 2;

            FOR i IN poliza.riesgos.first .. poliza.riesgos.last
            LOOP
               vpasexec := 3;

               IF poliza.riesgos.exists(i)
               THEN
                  vpasexec := 4;

                  IF poliza.riesgos(i).nriesgo = pnriesgo
                  THEN
                     vpasexec := 5;

                     IF poliza.riesgos(i).riesautos.exists(1)
                     THEN
                        vpasexec := 6;
                        poliza.riesgos(i).triesgo := ries.triesgo;
                        poliza.riesgos(i).riesautos(1) := autries;
                        vpasexec := 7;
                        RETURN 0;
                     ELSE
                        vpasexec := 7;
                        poliza.riesgos(i).triesgo := ries.triesgo;
                        poliza.riesgos(i).riesautos := t_iax_autriesgos();
                        poliza.riesgos(i).riesautos.extend;
                        poliza.riesgos(i).riesautos(1) := autries;
                        vpasexec := 8;
                        RETURN 0;
                     END IF;
                  END IF;
               END IF;
            END LOOP;

            -- No se modifica un registro, sino se dá de alta un nuevo registro en la coleccion ya existente
            poliza.riesgos.extend;
            poliza.riesgos(poliza.riesgos.last) := ob_iax_riesgos();
            poliza.riesgos(poliza.riesgos.last) := ries;
            poliza.riesgos(poliza.riesgos.last).riesautos := t_iax_autriesgos();
            poliza.riesgos(poliza.riesgos.last).riesautos.extend;
            poliza.riesgos(poliza.riesgos.last).riesautos(poliza.riesgos(poliza.riesgos.last).riesautos.last) := ob_iax_autriesgos();
            poliza.riesgos(poliza.riesgos.last).riesautos(poliza.riesgos(poliza.riesgos.last).riesautos.last) := autries;
            vpasexec := 9;
            RETURN 0;
            -- Bug 25378/137309 - 18/02/2013 - AMC
         ELSIF poliza.riesgos.count = 0
         THEN
            poliza.riesgos.extend;
            poliza.riesgos(poliza.riesgos.last) := ob_iax_riesgos();
            poliza.riesgos(poliza.riesgos.last) := ries;
            poliza.riesgos(poliza.riesgos.last).riesautos := t_iax_autriesgos();
            poliza.riesgos(poliza.riesgos.last).riesautos.extend;
            poliza.riesgos(poliza.riesgos.last).riesautos(poliza.riesgos(poliza.riesgos.last).riesautos.last) := ob_iax_autriesgos();
            poliza.riesgos(poliza.riesgos.last).riesautos(poliza.riesgos(poliza.riesgos.last).riesautos.last) := autries;
            RETURN 0;
            -- Fi Bug 25378/137309 - 18/02/2013 - AMC
         END IF;
      ELSE
         -- el objeto ob_iax_rieasgo no está inicializado
         vpasexec       := 9;
         poliza.riesgos := t_iax_riesgos();
         poliza.riesgos.extend;
         poliza.riesgos(poliza.riesgos.last) := ob_iax_riesgos();
         poliza.riesgos(poliza.riesgos.last) := ries;
         poliza.riesgos(poliza.riesgos.last).riesautos := t_iax_autriesgos();
         poliza.riesgos(poliza.riesgos.last).riesautos.extend;
         poliza.riesgos(poliza.riesgos.last).riesautos(poliza.riesgos(poliza.riesgos.last).riesautos.last) := ob_iax_autriesgos();
         poliza.riesgos(poliza.riesgos.last).riesautos(poliza.riesgos(poliza.riesgos.last).riesautos.last) := autries;
         vpasexec := 14;
         RETURN 0;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000646);
      RETURN 1;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_set_partriesautomovil;

   -- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_set_partriesautomovil

   -- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_set_PartAutAccesorios
   /*************************************************************************
      Sustituye el objeto accesorios del riesgo determinado
      param in poliza       : objeto poliza
      param in nriesgo      : número de riesgo
      param in acc         : objeto autaccesorios
      param in out mensajes : colección de mensajes
      return                : 0 todo correcto
                              1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_partautaccesorios(poliza   IN OUT ob_iax_detpoliza,
                                    pnriesgo IN NUMBER,
                                    accc     IN t_iax_autaccesorios,
                                    mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_Set_PartAutAccesorios';
   BEGIN
      IF poliza.riesgos IS NOT NULL
      THEN
         IF poliza.riesgos.count > 0
         THEN
            vpasexec := 2;

            FOR i IN poliza.riesgos.first .. poliza.riesgos.last
            LOOP
               vpasexec := 3;

               IF poliza.riesgos.exists(i)
               THEN
                  vpasexec := 4;

                  IF poliza.riesgos(i).nriesgo = pnriesgo
                  THEN
                     vpasexec := 5;

                     IF poliza.riesgos(i).riesautos.exists(1)
                     THEN
                        vpasexec := 6;

                        IF poliza.riesgos(i).riesautos(1).nriesgo = pnriesgo
                        THEN
                           vpasexec := 7;
                           -- IF poliza.riesgos(i).riesautos(1).accesorios is  THEN
                           vpasexec := 8;
                           poliza.riesgos(i).riesautos(1).accesorios := accc;
                           RETURN 0;
                           --ELSE
                           --  poliza.riesgos(i).riesautos(1).accesorios := t_iax_autaccesorios();
                           --  poliza.riesgos(i).riesautos.EXTEND;
                           --  poliza.riesgos(i).riesautos(1).accesorios := accc;
                           --  RETURN 0;
                           --END IF;
                        END IF;
                     END IF;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000646);
      RETURN 1;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_set_partautaccesorios;

   FUNCTION f_set_partautdispositivos(poliza   IN OUT ob_iax_detpoliza,
                                      pnriesgo IN NUMBER,
                                      disp     IN t_iax_autdispositivos,
                                      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_Set_partdispositivos';
   BEGIN
      IF poliza.riesgos IS NOT NULL
      THEN
         IF poliza.riesgos.count > 0
         THEN
            vpasexec := 2;

            FOR i IN poliza.riesgos.first .. poliza.riesgos.last
            LOOP
               vpasexec := 3;

               IF poliza.riesgos.exists(i)
               THEN
                  vpasexec := 4;

                  IF poliza.riesgos(i).nriesgo = pnriesgo
                  THEN
                     vpasexec := 5;

                     IF poliza.riesgos(i).riesautos.exists(1)
                     THEN
                        vpasexec := 6;

                        IF poliza.riesgos(i).riesautos(1).nriesgo = pnriesgo
                        THEN
                           vpasexec := 7;
                           -- IF poliza.riesgos(i).riesautos(1).accesorios is  THEN
                           vpasexec := 8;
                           poliza.riesgos(i).riesautos(1).dispositivos := disp;
                           RETURN 0;
                           --ELSE
                           --  poliza.riesgos(i).riesautos(1).accesorios := t_iax_autaccesorios();
                           --  poliza.riesgos(i).riesautos.EXTEND;
                           --  poliza.riesgos(i).riesautos(1).accesorios := accc;
                           --  RETURN 0;
                           --END IF;
                        END IF;
                     END IF;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000646);
      RETURN 1;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_set_partautdispositivos;

   -- Bug 9247 - APD - 12/03/2009 -- Se crea la funcion f_set_PartAutAccesorios
   /*************************************************************************
      Sustituye un asegurado de la coleccion de asegurados de los riesgo
      param in poliza       : objeto riesgo
      param in aseg          : objeto asegurados
      param in out mensajes : colección de mensajes
      return                : 0 todo correcto
                              1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_partriesasegurado(poliza   IN OUT ob_iax_detpoliza,
                                    nriesgo  IN NUMBER,
                                    aseg     IN ob_iax_asegurados,
                                    mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_Set_partriesasegurado';
   BEGIN
      IF poliza.riesgos IS NOT NULL
      THEN
         vpasexec := 2;

         IF poliza.riesgos.count > 0
         THEN
            vpasexec := 3;

            FOR j IN poliza.riesgos.first .. poliza.riesgos.last
            LOOP
               vpasexec := 4;

               IF poliza.riesgos.exists(j)
               THEN
                  vpasexec := 5;

                  IF poliza.riesgos(j).nriesgo = nriesgo
                  THEN
                     IF poliza.riesgos(j).riesgoase IS NOT NULL
                     THEN
                        IF poliza.riesgos(j).riesgoase.count > 0
                        THEN
                           FOR i IN poliza.riesgos(j).riesgoase.first .. poliza.riesgos(j)
                                                                         .riesgoase.last
                           LOOP
                              IF poliza.riesgos(j).riesgoase(i)
                               .sperson = aseg.sperson
                              THEN
                                 poliza.riesgos(j).riesgoase(i) := aseg;
                              END IF;
                           END LOOP;
                        END IF;
                     END IF;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_set_partriesasegurado;

   /*************************************************************************
      Devuelve parte del objeto riesgo a un objeto saldo deutors
      param in riesgo       : objeto riesgo
      param in out mensajes : colección de mensajes
      return                : objeto colección saldos deutors
   *************************************************************************/
   FUNCTION f_partriessaldodeutor(riesgo   IN ob_iax_riesgos,
                                  mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prestamoseg IS
      prestamo t_iax_prestamoseg;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_partriessaldodeutor';
   BEGIN
      IF riesgo IS NOT NULL
      THEN
         IF riesgo.prestamo IS NOT NULL
         THEN
            vpasexec := 2;
            RETURN riesgo.prestamo;
         END IF;
      END IF;

      vpasexec := 3;
      prestamo := t_iax_prestamoseg();
      RETURN prestamo;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_partriessaldodeutor;

   -- Bug 10702 - XPL - 22/07/2009 -- Se crea la funcion f_set_partriessaldodeutor
   /*************************************************************************
      Graba en el objeto saldo deutors el objeto pasado por parametro
      param in poliza       : objeto poliza
      param in nriesgo       : num. riesgo
      param in selsaldo       : marcado o no
      param in saldo          : objeto saldo deutor
      param in out mensajes : colección de mensajes
      return                : 0 todo correcto
                              1 ha habido un error
   *************************************************************************/
   -- Bug 11165 - 16/09/2009 - AMC - Se sustituñe  ob_iax_saldodeutorseg por ob_iax_prestamoseg
   FUNCTION f_set_partriessaldodeutor(poliza   IN OUT ob_iax_detpoliza,
                                      nriesgo  IN NUMBER,
                                      selsaldo IN NUMBER,
                                      saldo    IN ob_iax_prestamoseg,
                                      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_Set_partriessaldodeutor';
      trobat   BOOLEAN := FALSE;
      vexiste  BOOLEAN := FALSE;
      v_index  NUMBER;
   BEGIN
      IF poliza.riesgos IS NOT NULL
      THEN
         vpasexec := 2;

         IF poliza.riesgos.count > 0
         THEN
            vpasexec := 3;

            IF nriesgo IS NOT NULL
            THEN
               vpasexec := 10;

               FOR vrie IN poliza.riesgos.first .. poliza.riesgos.last
               LOOP
                  IF poliza.riesgos.exists(vrie)
                  THEN
                     IF poliza.riesgos(vrie).nriesgo = nriesgo
                     THEN
                        vpasexec := 11;

                        -- Bug 11165 - 16/09/2009 - AMC
                        IF poliza.riesgos(vrie)
                         .prestamo IS NOT NULL AND
                           poliza.riesgos(vrie).prestamo.count > 0
                        THEN
                           FOR vsaldo IN poliza.riesgos(vrie).prestamo.first .. poliza.riesgos(vrie)
                                                                                .prestamo.last
                           LOOP
                              IF poliza.riesgos(vrie).prestamo(vsaldo)
                               .idcuenta = saldo.idcuenta
                              THEN
                                 trobat := TRUE;

                                 IF selsaldo = 0
                                 THEN
                                    poliza.riesgos(vrie).prestamo(vsaldo).selsaldo := 0;
                                 ELSIF selsaldo = 1
                                 THEN
                                    poliza.riesgos(vrie).prestamo(vsaldo).ctipcuenta := saldo.ctipcuenta;
                                    poliza.riesgos(vrie).prestamo(vsaldo).ttipcuenta := saldo.ttipcuenta;
                                    poliza.riesgos(vrie).prestamo(vsaldo).ctipban := saldo.ctipban;
                                    poliza.riesgos(vrie).prestamo(vsaldo).ttipban := saldo.ttipban;
                                    poliza.riesgos(vrie).prestamo(vsaldo).ctipimp := saldo.ctipimp;
                                    poliza.riesgos(vrie).prestamo(vsaldo).ttipimp := saldo.ttipimp;
                                    poliza.riesgos(vrie).prestamo(vsaldo).isaldo := saldo.isaldo;
                                    poliza.riesgos(vrie).prestamo(vsaldo).porcen := saldo.porcen;
                                    poliza.riesgos(vrie).prestamo(vsaldo).ilimite := saldo.ilimite;
                                    poliza.riesgos(vrie).prestamo(vsaldo).icapmax := saldo.icapmax;
                                    poliza.riesgos(vrie).prestamo(vsaldo).cmoneda := saldo.cmoneda;
                                    poliza.riesgos(vrie).prestamo(vsaldo).selsaldo := selsaldo;
                                    poliza.riesgos(vrie).prestamo(vsaldo).icapaseg := saldo.icapaseg;
                                    poliza.riesgos(vrie).prestamo(vsaldo).descripcion := saldo.descripcion;
                                    poliza.riesgos(vrie).prestamo(vsaldo).nmovimi := NVL(poliza.nmovimi,
                                                                                         1); -- BUG10569:DRA:03/09/2009
                                    poliza.riesgos(vrie).prestamo(vsaldo).descripcion := saldo.descripcion;
                                    poliza.riesgos(vrie).prestamo(vsaldo).finiprest := saldo.finiprest;
                                    poliza.riesgos(vrie).prestamo(vsaldo).ffinprest := saldo.ffinprest;
                                 END IF;
                              END IF;
                           END LOOP;
                        END IF;

                        IF trobat = FALSE
                        THEN
                           --creamos uno nuevo
                           IF poliza.riesgos(vrie).prestamo IS NULL
                           THEN
                              poliza.riesgos(vrie).prestamo := t_iax_prestamoseg();
                           END IF;

                           poliza.riesgos(vrie).prestamo.extend;
                           v_index := poliza.riesgos(vrie).prestamo.last;
                           poliza.riesgos(vrie).prestamo(v_index) := ob_iax_prestamoseg();
                           poliza.riesgos(vrie).prestamo(v_index).idcuenta := saldo.idcuenta;
                           poliza.riesgos(vrie).prestamo(v_index).ctipcuenta := saldo.ctipcuenta;
                           poliza.riesgos(vrie).prestamo(v_index).ttipcuenta := saldo.ttipcuenta;
                           poliza.riesgos(vrie).prestamo(v_index).ctipban := saldo.ctipban;
                           poliza.riesgos(vrie).prestamo(v_index).ttipban := saldo.ttipban;
                           poliza.riesgos(vrie).prestamo(v_index).ctipimp := saldo.ctipimp;
                           poliza.riesgos(vrie).prestamo(v_index).ttipimp := saldo.ttipimp;
                           poliza.riesgos(vrie).prestamo(v_index).isaldo := saldo.isaldo;
                           poliza.riesgos(vrie).prestamo(v_index).porcen := saldo.porcen;
                           poliza.riesgos(vrie).prestamo(v_index).ilimite := saldo.ilimite;
                           poliza.riesgos(vrie).prestamo(v_index).icapmax := saldo.icapmax;
                           poliza.riesgos(vrie).prestamo(v_index).cmoneda := saldo.cmoneda;
                           poliza.riesgos(vrie).prestamo(v_index).selsaldo := selsaldo;
                           poliza.riesgos(vrie).prestamo(v_index).icapaseg := saldo.icapaseg;
                           poliza.riesgos(vrie).prestamo(v_index).descripcion := saldo.descripcion;
                           poliza.riesgos(vrie).prestamo(v_index).nmovimi := NVL(poliza.nmovimi,
                                                                                 1); -- BUG10569:DRA:03/09/2009
                           poliza.riesgos(vrie).prestamo(v_index).finiprest := saldo.finiprest;
                           poliza.riesgos(vrie).prestamo(v_index).ffinprest := saldo.ffinprest;
                        END IF;
                        --Fi Bug 11165 - 16/09/2009 - AMC
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_set_partriessaldodeutor;

   /*************************************************************************
      Devuelve parte del objeto poliza a un objeto reglasseg
      param in poliza       : objeto detalle póliza
      param in out mensajes : colección de mensajes
      return                : objeto gestion
   *************************************************************************/
   -- Bug 16106 - RSC - 23/09/2010 - APR - Ajustes e implementación para el alta de colectivos
   FUNCTION f_partpoldatosreglasseg(poliza   IN OUT ob_iax_detpoliza,
                                    pnriesgo IN NUMBER,
                                    pcgarant IN NUMBER,
                                    mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_reglasseg IS
      reglas   ob_iax_reglasseg;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.f_partpoldatosreglasseg';
   BEGIN
      IF poliza.riesgos IS NOT NULL
      THEN
         vpasexec := 2;

         IF poliza.riesgos.count > 0
         THEN
            vpasexec := 3;

            IF pnriesgo IS NOT NULL
            THEN
               vpasexec := 4;

               FOR vrie IN poliza.riesgos.first .. poliza.riesgos.last
               LOOP
                  IF poliza.riesgos.exists(vrie)
                  THEN
                     IF poliza.riesgos(vrie).nriesgo = pnriesgo
                     THEN
                        vpasexec := 5;

                        IF poliza.riesgos(vrie)
                         .garantias IS NOT NULL AND
                           poliza.riesgos(vrie).garantias.count > 0
                        THEN
                           vpasexec := 6;

                           FOR vgar IN poliza.riesgos(vrie).garantias.first .. poliza.riesgos(vrie)
                                                                               .garantias.last
                           LOOP
                              vpasexec := 7;

                              IF poliza.riesgos(vrie).garantias.exists(vgar)
                              THEN
                                 IF poliza.riesgos(vrie).garantias(vgar)
                                  .cgarant = pcgarant
                                 THEN
                                    vpasexec := 8;

                                    -------------------------------------------
                                    --IF pac_seguros.f_get_escertifcero(poliza.npoliza) > 0 THEN
                                    IF poliza.riesgos(vrie).garantias(vgar)
                                     .reglasseg IS NOT NULL
                                    THEN
                                       RETURN poliza.riesgos(vrie).garantias(vgar).reglasseg;
                                    END IF;

                                    reglas := ob_iax_reglasseg();
                                    poliza.riesgos(vrie).garantias(vgar).reglasseg := reglas;
                                    /*ELSE
                                       reglas :=
                                          f_getreglas_cert0(poliza.sseguro, pnriesgo,
                                                            pcgarant, mensajes);
                                       poliza.riesgos(vrie).garantias(vgar).reglasseg :=
                                                                                        reglas;
                                    END IF;*/
                                    -------------------------------------------
                                 END IF;
                              END IF;
                           END LOOP;
                        END IF;
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         END IF;
      END IF;

      RETURN reglas;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_partpoldatosreglasseg;

   /*************************************************************************
      Devuelve parte del objeto poliza a un objeto reglasseg
      param in poliza       : objeto detalle póliza
      param in out mensajes : colección de mensajes
      return                : objeto gestion
   *************************************************************************/
   FUNCTION f_partpoldatosreglassegtramos(poliza   IN OUT ob_iax_detpoliza,
                                          pnriesgo IN NUMBER,
                                          pcgarant IN NUMBER,
                                          mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_reglassegtramos IS
      reglas   t_iax_reglassegtramos;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.f_partpoldatosreglassegtramos';
   BEGIN
      IF poliza.riesgos IS NOT NULL
      THEN
         vpasexec := 2;

         IF poliza.riesgos.count > 0
         THEN
            vpasexec := 3;

            IF pnriesgo IS NOT NULL
            THEN
               vpasexec := 4;

               FOR vrie IN poliza.riesgos.first .. poliza.riesgos.last
               LOOP
                  IF poliza.riesgos.exists(vrie)
                  THEN
                     IF poliza.riesgos(vrie).nriesgo = pnriesgo
                     THEN
                        vpasexec := 5;

                        IF poliza.riesgos(vrie)
                         .garantias IS NOT NULL AND
                           poliza.riesgos(vrie).garantias.count > 0
                        THEN
                           vpasexec := 6;

                           FOR vgar IN poliza.riesgos(vrie).garantias.first .. poliza.riesgos(vrie)
                                                                               .garantias.last
                           LOOP
                              vpasexec := 7;

                              IF poliza.riesgos(vrie).garantias.exists(vgar)
                              THEN
                                 IF poliza.riesgos(vrie).garantias(vgar)
                                  .cgarant = pcgarant
                                 THEN
                                    vpasexec := 8;

                                    IF poliza.riesgos(vrie).garantias(vgar)
                                     .reglasseg IS NOT NULL
                                    THEN
                                       IF poliza.riesgos(vrie).garantias(vgar)
                                        .reglasseg.reglassegtramos IS NOT NULL
                                       THEN
                                          RETURN poliza.riesgos(vrie).garantias(vgar).reglasseg.reglassegtramos;
                                       END IF;

                                       reglas := t_iax_reglassegtramos();
                                       poliza.riesgos(vrie).garantias(vgar).reglasseg.reglassegtramos := reglas;
                                    END IF;
                                 END IF;
                              END IF;
                           END LOOP;
                        END IF;
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         END IF;
      END IF;

      RETURN reglas;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_partpoldatosreglassegtramos;

   FUNCTION f_limpiar_tramos(reglas IN t_iax_reglassegtramos)
      RETURN t_iax_reglassegtramos IS
      reglas_out t_iax_reglassegtramos := t_iax_reglassegtramos();
   BEGIN
      FOR i IN reglas.first .. reglas.last
      LOOP
         IF reglas(i).edadfin != 0
         THEN
            reglas_out.extend;
            reglas_out(reglas_out.last) := reglas(i);
         END IF;
      END LOOP;

      IF reglas_out.count < 1
      THEN
         reglas_out.extend;
         reglas_out(1) := ob_iax_reglassegtramos();
         reglas_out(1).sseguro := reglas(1).sseguro;
         reglas_out(1).nriesgo := reglas(1).nriesgo;
         reglas_out(1).nmovimi := reglas(1).nmovimi;
         reglas_out(1).cgarant := reglas(1).cgarant;
         reglas_out(1).edadini := 0;
         reglas_out(1).edadfin := 0;
         reglas_out(1).t1copagemp := 0;
         reglas_out(1).t1copagtra := 0;
         reglas_out(1).t2copagemp := 0;
         reglas_out(1).t2copagtra := 0;
         reglas_out(1).t3copagemp := 0;
         reglas_out(1).t3copagtra := 0;
         reglas_out(1).t4copagemp := 0;
         reglas_out(1).t4copagtra := 0;
      END IF;

      RETURN reglas_out;
   END f_limpiar_tramos;

   /*************************************************************************
      Graba parte del objeto poliza a un objeto reglasseg
      param in poliza       : objeto detalle póliza
      param in out mensajes : colección de mensajes
      return                : objeto gestion
   *************************************************************************/
   FUNCTION f_set_partpoldatosregla(poliza     IN OUT ob_iax_detpoliza,
                                    pnriesgo   IN NUMBER,
                                    pcgarant   IN NUMBER,
                                    pcapmaxemp IN NUMBER,
                                    pcapminemp IN NUMBER,
                                    pcapmaxtra IN NUMBER,
                                    pcapmintra IN NUMBER,
                                    mensajes   IN OUT t_iax_mensajes)
      RETURN ob_iax_reglasseg IS
      reglas   ob_iax_reglasseg;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.f_set_partpoldatosregla';
   BEGIN
      IF poliza.riesgos IS NOT NULL
      THEN
         vpasexec := 2;

         IF poliza.riesgos.count > 0
         THEN
            vpasexec := 3;

            IF pnriesgo IS NOT NULL
            THEN
               vpasexec := 4;

               FOR vrie IN poliza.riesgos.first .. poliza.riesgos.last
               LOOP
                  IF poliza.riesgos.exists(vrie)
                  THEN
                     IF poliza.riesgos(vrie).nriesgo = pnriesgo
                     THEN
                        vpasexec := 5;

                        IF poliza.riesgos(vrie)
                         .garantias IS NOT NULL AND
                           poliza.riesgos(vrie).garantias.count > 0
                        THEN
                           vpasexec := 6;

                           FOR vgar IN poliza.riesgos(vrie).garantias.first .. poliza.riesgos(vrie)
                                                                               .garantias.last
                           LOOP
                              vpasexec := 7;

                              IF poliza.riesgos(vrie).garantias.exists(vgar)
                              THEN
                                 IF poliza.riesgos(vrie).garantias(vgar)
                                  .cgarant = pcgarant
                                 THEN
                                    vpasexec := 8;

                                    IF poliza.riesgos(vrie).garantias(vgar)
                                     .reglasseg IS NOT NULL
                                    THEN
                                       poliza.riesgos(vrie).garantias(vgar).reglasseg.sseguro := poliza.sseguro;
                                       poliza.riesgos(vrie).garantias(vgar).reglasseg.nriesgo := pnriesgo;
                                       poliza.riesgos(vrie).garantias(vgar).reglasseg.nmovimi := poliza.nmovimi;
                                       poliza.riesgos(vrie).garantias(vgar).reglasseg.cgarant := pcgarant;
                                       poliza.riesgos(vrie).garantias(vgar).reglasseg.capmaxemp := pcapmaxemp;
                                       poliza.riesgos(vrie).garantias(vgar).reglasseg.capmaxtra := pcapmaxtra;
                                       poliza.riesgos(vrie).garantias(vgar).reglasseg.capminemp := pcapminemp;
                                       poliza.riesgos(vrie).garantias(vgar).reglasseg.capmintra := pcapmintra;

                                       IF poliza.riesgos(vrie).garantias(vgar)
                                        .reglasseg.reglassegtramos.count > 1
                                       THEN
                                          poliza.riesgos(vrie).garantias(vgar).reglasseg.reglassegtramos := f_limpiar_tramos(poliza.riesgos(vrie).garantias(vgar)
                                                                                                                             .reglasseg.reglassegtramos);
                                       END IF;

                                       RETURN poliza.riesgos(vrie).garantias(vgar).reglasseg;
                                    END IF;

                                    reglas           := ob_iax_reglasseg();
                                    reglas.sseguro   := poliza.sseguro;
                                    reglas.nriesgo   := pnriesgo;
                                    reglas.nmovimi   := poliza.nmovimi;
                                    reglas.cgarant   := pcgarant;
                                    reglas.capmaxemp := pcapmaxemp;
                                    reglas.capmaxtra := pcapmaxtra;
                                    reglas.capminemp := pcapminemp;
                                    reglas.capmintra := pcapmintra;
                                    --
                                    reglas.reglassegtramos := f_limpiar_tramos(reglas.reglassegtramos);
                                    --
                                    poliza.riesgos(vrie).garantias(vgar).reglasseg := reglas;
                                 END IF;
                              END IF;
                           END LOOP;
                        END IF;
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         END IF;
      END IF;

      RETURN reglas;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_set_partpoldatosregla;

   /*************************************************************************
      Graba parte del objeto poliza a un objeto reglasseg
      param in poliza       : objeto detalle póliza
      param in out mensajes : colección de mensajes
      return                : objeto gestion
   *************************************************************************/
   FUNCTION f_set_partpoldatosreglatramos(poliza   IN OUT ob_iax_detpoliza,
                                          pnriesgo IN NUMBER,
                                          pcgarant IN NUMBER,
                                          pnumbloq IN NUMBER,
                                          pedadini IN NUMBER,
                                          pedadfin IN NUMBER,
                                          pt1emp   IN NUMBER,
                                          pt1trab  IN NUMBER,
                                          pt2emp   IN NUMBER,
                                          pt2trab  IN NUMBER,
                                          pt3emp   IN NUMBER,
                                          pt3trab  IN NUMBER,
                                          pt4emp   IN NUMBER,
                                          pt4trab  IN NUMBER,
                                          mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_reglassegtramos IS
      reglas   t_iax_reglassegtramos;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.f_set_partpoldatosreglatramos';
   BEGIN
      IF poliza.riesgos IS NOT NULL
      THEN
         vpasexec := 2;

         IF poliza.riesgos.count > 0
         THEN
            vpasexec := 3;

            IF pnriesgo IS NOT NULL
            THEN
               vpasexec := 4;

               FOR vrie IN poliza.riesgos.first .. poliza.riesgos.last
               LOOP
                  IF poliza.riesgos.exists(vrie)
                  THEN
                     IF poliza.riesgos(vrie).nriesgo = pnriesgo
                     THEN
                        vpasexec := 5;

                        IF poliza.riesgos(vrie)
                         .garantias IS NOT NULL AND
                           poliza.riesgos(vrie).garantias.count > 0
                        THEN
                           vpasexec := 6;

                           FOR vgar IN poliza.riesgos(vrie).garantias.first .. poliza.riesgos(vrie)
                                                                               .garantias.last
                           LOOP
                              vpasexec := 7;

                              IF poliza.riesgos(vrie).garantias.exists(vgar)
                              THEN
                                 IF poliza.riesgos(vrie).garantias(vgar)
                                  .cgarant = pcgarant
                                 THEN
                                    vpasexec := 8;

                                    IF poliza.riesgos(vrie).garantias(vgar)
                                     .reglasseg IS NOT NULL
                                    THEN
                                       IF poliza.riesgos(vrie).garantias(vgar)
                                        .reglasseg.reglassegtramos IS NOT NULL
                                       THEN
                                          IF pnumbloq > poliza.riesgos(vrie).garantias(vgar)
                                            .reglasseg.reglassegtramos.count
                                          THEN
                                             IF pnumbloq = poliza.riesgos(vrie).garantias(vgar)
                                               .reglasseg.reglassegtramos.count + 1
                                             THEN
                                                poliza.riesgos(vrie).garantias(vgar).reglasseg.reglassegtramos.extend;
                                             ELSE
                                                pac_iobj_mensajes.crea_nuevo_mensaje(mensajes,
                                                                                     1,
                                                                                     1000644);
                                                RETURN NULL;
                                             END IF;
                                          END IF;

                                          poliza.riesgos(vrie).garantias(vgar).reglasseg.reglassegtramos(pnumbloq) := ob_iax_reglassegtramos();
                                          poliza.riesgos(vrie).garantias(vgar).reglasseg.reglassegtramos(pnumbloq).sseguro := poliza.sseguro;
                                          poliza.riesgos(vrie).garantias(vgar).reglasseg.reglassegtramos(pnumbloq).nriesgo := pnriesgo;
                                          poliza.riesgos(vrie).garantias(vgar).reglasseg.reglassegtramos(pnumbloq).nmovimi := poliza.nmovimi;
                                          poliza.riesgos(vrie).garantias(vgar).reglasseg.reglassegtramos(pnumbloq).cgarant := pcgarant;
                                          poliza.riesgos(vrie).garantias(vgar).reglasseg.reglassegtramos(pnumbloq).edadini := pedadini;
                                          poliza.riesgos(vrie).garantias(vgar).reglasseg.reglassegtramos(pnumbloq).edadfin := pedadfin;
                                          poliza.riesgos(vrie).garantias(vgar).reglasseg.reglassegtramos(pnumbloq).t1copagemp := pt1emp;
                                          poliza.riesgos(vrie).garantias(vgar).reglasseg.reglassegtramos(pnumbloq).t1copagtra := pt1trab;
                                          poliza.riesgos(vrie).garantias(vgar).reglasseg.reglassegtramos(pnumbloq).t2copagemp := pt2emp;
                                          poliza.riesgos(vrie).garantias(vgar).reglasseg.reglassegtramos(pnumbloq).t2copagtra := pt2trab;
                                          poliza.riesgos(vrie).garantias(vgar).reglasseg.reglassegtramos(pnumbloq).t3copagemp := pt3emp;
                                          poliza.riesgos(vrie).garantias(vgar).reglasseg.reglassegtramos(pnumbloq).t3copagtra := pt3trab;
                                          poliza.riesgos(vrie).garantias(vgar).reglasseg.reglassegtramos(pnumbloq).t4copagemp := pt4emp;
                                          poliza.riesgos(vrie).garantias(vgar).reglasseg.reglassegtramos(pnumbloq).t4copagtra := pt4trab;
                                          RETURN poliza.riesgos(vrie).garantias(vgar).reglasseg.reglassegtramos;
                                       END IF;

                                       reglas := t_iax_reglassegtramos();
                                       reglas.extend;
                                       reglas(pnumbloq) := ob_iax_reglassegtramos();
                                       reglas(pnumbloq).sseguro := poliza.sseguro;
                                       reglas(pnumbloq).nriesgo := pnriesgo;
                                       reglas(pnumbloq).nmovimi := poliza.nmovimi;
                                       reglas(pnumbloq).cgarant := pcgarant;
                                       reglas(pnumbloq).edadini := pedadini;
                                       reglas(pnumbloq).edadfin := pedadfin;
                                       reglas(pnumbloq).t1copagemp := pt1emp;
                                       reglas(pnumbloq).t1copagtra := pt1trab;
                                       reglas(pnumbloq).t2copagemp := pt2emp;
                                       reglas(pnumbloq).t2copagtra := pt2trab;
                                       reglas(pnumbloq).t3copagemp := pt3emp;
                                       reglas(pnumbloq).t3copagtra := pt3trab;
                                       reglas(pnumbloq).t4copagemp := pt4emp;
                                       reglas(pnumbloq).t4copagtra := pt4trab;
                                       poliza.riesgos(vrie).garantias(vgar).reglasseg.reglassegtramos := reglas;
                                    END IF;
                                 END IF;
                              END IF;
                           END LOOP;
                        END IF;
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         END IF;
      END IF;

      RETURN reglas;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_set_partpoldatosreglatramos;

   /*************************************************************************
      Obté les regles del certificat 0
      param in psseguro     : id del seguro
      param in pnriesgo     : id del riesgo
      param in pcgarant     : id de la garantia
      param in out mensajes : colección de mensajes
      return                : objeto reglasseg
   *************************************************************************/
   FUNCTION f_getreglas_cert0(psseguro IN NUMBER,
                              pnriesgo IN NUMBER,
                              pcgarant IN NUMBER,
                              pnpoliza IN NUMBER,
                              mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_reglasseg IS
      reglas       ob_iax_reglasseg := ob_iax_reglasseg();
      reglastramos t_iax_reglassegtramos;
      vsseguro     NUMBER;
      vnmovimi     NUMBER;
      vpasexec     NUMBER(8) := 1;
      vparam       VARCHAR2(1) := NULL;
      vobject      VARCHAR2(200) := 'PAC_IOBJ_PROD.f_getreglas_cert0';

      CURSOR cur_reg IS
         SELECT nmovimi,
                capmaxemp,
                capminemp,
                capmaxtra,
                capmintra
           FROM reglasseg
          WHERE sseguro = vsseguro
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM reglasseg
                            WHERE sseguro = vsseguro
                              AND nriesgo = pnriesgo
                              AND cgarant = pcgarant);

      CURSOR cur_regt IS
         SELECT edadini,
                edadfin,
                t1copagemp,
                t1copagtra,
                t2copagemp,
                t2copagtra,
                t3copagemp,
                t3copagtra,
                t4copagemp,
                t4copagtra
           FROM reglassegtramos
          WHERE sseguro = vsseguro
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant
            AND nmovimi = vnmovimi;
   BEGIN
      -- BUG24804:DRA:18/02/2013:Inici: Si no troba registres que retorni NULL per? error
      BEGIN
         SELECT sseguro
           INTO vsseguro
           FROM seguros
          WHERE npoliza = pnpoliza
               -- (SELECT npoliza
               --                FROM estseguros
               --             WHERE sseguro = psseguro)
            AND ncertif = 0;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN NULL;
      END;

      vpasexec := 2;

      FOR reg IN cur_reg
      LOOP
         vnmovimi         := reg.nmovimi;
         reglas.sseguro   := psseguro;
         reglas.nriesgo   := pnriesgo;
         reglas.cgarant   := pcgarant;
         reglas.nmovimi   := vnmovimi;
         reglas.capmaxemp := reg.capmaxemp;
         reglas.capminemp := reg.capminemp;
         reglas.capmaxtra := reg.capmaxtra;
         reglas.capmintra := reg.capmintra;
         vpasexec         := 3;
         reglastramos     := t_iax_reglassegtramos();

         FOR regt IN cur_regt
         LOOP
            reglastramos.extend;
            reglastramos(reglastramos.last) := ob_iax_reglassegtramos();
            reglastramos(reglastramos.last).sseguro := psseguro;
            reglastramos(reglastramos.last).nriesgo := pnriesgo;
            reglastramos(reglastramos.last).cgarant := pcgarant;
            reglastramos(reglastramos.last).nmovimi := vnmovimi;
            reglastramos(reglastramos.last).edadini := regt.edadini;
            reglastramos(reglastramos.last).edadfin := regt.edadfin;
            reglastramos(reglastramos.last).t1copagemp := regt.t1copagemp;
            reglastramos(reglastramos.last).t1copagtra := regt.t1copagtra;
            reglastramos(reglastramos.last).t2copagemp := regt.t2copagemp;
            reglastramos(reglastramos.last).t2copagtra := regt.t2copagtra;
            reglastramos(reglastramos.last).t3copagemp := regt.t3copagemp;
            reglastramos(reglastramos.last).t3copagtra := regt.t3copagtra;
            reglastramos(reglastramos.last).t4copagemp := regt.t4copagemp;
            reglastramos(reglastramos.last).t4copagtra := regt.t4copagtra;
         END LOOP;

         IF reglastramos.count > 0
         THEN
            reglas.reglassegtramos := reglastramos;
            vpasexec               := 4;
            RETURN reglas;
         END IF;
      END LOOP;

      vpasexec := 5;
      RETURN NULL;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_getreglas_cert0;

   -- Fin Bug 16106

   -- ini 19276, jbn, reemplazos
   /*************************************************************************
      Devuelve parte del objeto poliza a un objeto reemplazos
      param in poliza       : objeto detalle póliza
      param in out mensajes : colección de mensajes
      return                : objeto colección tomadores
   *************************************************************************/
   FUNCTION f_partpolreemplazos(poliza   IN ob_iax_detpoliza,
                                mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_reemplazos IS
      reemplazos t_iax_reemplazos;
      vpasexec   NUMBER(8) := 1;
      vparam     VARCHAR2(1) := NULL;
      vobject    VARCHAR2(200) := 'PAC_IOBJ_PROD.F_PARTPOLREEMPLAZOS';
   BEGIN
      IF poliza.reemplazos IS NOT NULL
      THEN
         IF poliza.reemplazos.count > 0
         THEN
            RETURN poliza.reemplazos;
         END IF;
      END IF;

      RETURN t_iax_reemplazos();
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_partpolreemplazos;

   -- fin 19276, jbn, reemplazos

   --Bug.: 19152 - 21/10/2011 - ICV
   /*************************************************************************
      Devuelve parte del objeto ob_iax_beneidentificados riesgo
      param in riesgo       : objeto riesgo
      param in pnorden      : Posición del objeto
      param in out mensajes : colección de mensajes
      return                : objeto garantia
   *************************************************************************/
   FUNCTION f_partriesbeneident_r(riesgo   IN ob_iax_riesgos,
                                  psseguro IN NUMBER,
                                  pnorden  IN NUMBER,
                                  mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_beneidentificados IS
      vpasexec    NUMBER(8) := 1;
      vparam      VARCHAR2(1000) := 'pnorden : ' || pnorden;
      vobject     VARCHAR2(200) := 'PAC_IOBJ_PROD.F_partriesbeneident_r';
      rie         ob_iax_riesgos := ob_iax_riesgos();
      v_agenvisio NUMBER;
   BEGIN
      rie := riesgo;

      IF rie IS NOT NULL
      THEN
         IF rie.beneficiario.benefesp IS NOT NULL
         THEN
            vpasexec := 2;

            IF rie.beneficiario.benefesp.benef_riesgo.count > 0
            THEN
               FOR i IN rie.beneficiario.benefesp.benef_riesgo.first .. rie.beneficiario.benefesp.benef_riesgo.last
               LOOP
                  vpasexec := 4;

                  IF rie.beneficiario.benefesp.benef_riesgo.exists(i)
                  THEN
                     vpasexec := 5;

                     IF rie.beneficiario.benefesp.benef_riesgo(i)
                      .norden = pnorden
                     THEN
                        BEGIN
                           BEGIN
                              SELECT cagente
                                INTO v_agenvisio
                                FROM estseguros ss
                               WHERE ss.sseguro = psseguro;
                           EXCEPTION
                              WHEN OTHERS THEN
                                 v_agenvisio := ff_agenteprod;
                           END;
                           --
                           SELECT ff_desvalorfijo(672,
                                                  pac_md_common.f_get_cxtidioma(),
                                                  ctipide),
                                  nnumide,
                                  ed.tapelli1 || ' ' || ed.tapelli2 || ', ' ||
                                  ed.tnombre
                             INTO rie.beneficiario.benefesp.benef_riesgo(i)
                                  .ttipide,
                                  rie.beneficiario.benefesp.benef_riesgo(i)
                                  .nnumide,
                                  rie.beneficiario.benefesp.benef_riesgo(i)
                                  .nombre_ben
                             FROM estper_personas ep,
                                  estper_detper   ed
                            WHERE ep.sperson = rie.beneficiario.benefesp.benef_riesgo(i)
                                 .sperson
                              AND ep.sperson = ed.sperson
                              AND ed.cagente =
                                  ff_agente_cpervisio(v_agenvisio);
                        EXCEPTION
                           WHEN OTHERS THEN
							--INI IAXIS-4203 CJMR 26/06/2019
							BEGIN
							   SELECT ff_desvalorfijo(672,pac_md_common.f_get_cxtidioma(),ctipide),
									  nnumide,
									  ed.tapelli1 || ' ' || ed.tapelli2 || ', ' || ed.tnombre
								 INTO rie.beneficiario.benefesp.benef_riesgo(i).ttipide,
									  rie.beneficiario.benefesp.benef_riesgo(i).nnumide,
									  rie.beneficiario.benefesp.benef_riesgo(i).nombre_ben
								 FROM per_personas ep,
									  per_detper   ed
								WHERE ep.sperson = rie.beneficiario.benefesp.benef_riesgo(i).sperson
								  AND ep.sperson = ed.sperson;
							EXCEPTION
							   WHEN OTHERS THEN
								  rie.beneficiario.benefesp.benef_riesgo(i).ttipide := '**';
								  rie.beneficiario.benefesp.benef_riesgo(i).nnumide := '**';
								  rie.beneficiario.benefesp.benef_riesgo(i).nombre_ben := '**';
							END;
							--FIN IAXIS-4203 CJMR 26/06/2019
                        END;

                        -- 34866 / 209952
                        --
                        IF (rie.beneficiario.benefesp.benef_riesgo(i)
                           .ctipocon IS NOT NULL)
                        THEN
                           rie.beneficiario.benefesp.benef_riesgo(i).ttipocon := ff_desvalorfijo(8001024,
                                                                                                 pac_md_common.f_get_cxtidioma(),
                                                                                                 rie.beneficiario.benefesp.benef_riesgo(i)
                                                                                                 .ctipocon);
                        END IF;

                        RETURN rie.beneficiario.benefesp.benef_riesgo(i);
                     END IF;
                  END IF;
               END LOOP;

               vpasexec := 6;
            END IF;
         END IF;
      END IF;

      vpasexec := 7;
      RETURN NULL;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_partriesbeneident_r;

   /*************************************************************************
      Devuelve parte del objeto ob_iax_beneidentificados garantía
      param in riesgo       : objeto riesgo
      param in pnorden      : Posición del objeto
      param in out mensajes : colección de mensajes
      return                : objeto garantia
   *************************************************************************/
   FUNCTION f_partriesbeneident_g(riesgo   IN ob_iax_riesgos,
                                  pnorden  IN NUMBER,
                                  pcgarant IN NUMBER,
                                  mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_beneidentificados IS
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1000) := 'pnorden : ' || pnorden || ' pcgarant : ' ||
                                 pcgarant;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_partriesbeneident_g';
      rie      ob_iax_riesgos := ob_iax_riesgos();
   BEGIN
      rie := riesgo;

      IF rie IS NOT NULL
      THEN
         IF rie.beneficiario.benefesp IS NOT NULL
         THEN
            vpasexec := 2;

            IF rie.beneficiario.benefesp.benefesp_gar.count > 0
            THEN
               --Nos situamos en la garantía
               FOR i IN rie.beneficiario.benefesp.benefesp_gar.first .. rie.beneficiario.benefesp.benefesp_gar.last
               LOOP
                  vpasexec := 4;

                  IF rie.beneficiario.benefesp.benefesp_gar.exists(i)
                  THEN
                     vpasexec := 5;

                     IF rie.beneficiario.benefesp.benefesp_gar(i)
                      .cgarant = pcgarant
                     THEN
                        --Ahora nos posibionamos dentro de la colección de beneidentificados
                        vpasexec := 6;

                        IF rie.beneficiario.benefesp.benefesp_gar(i)
                         .benef_ident.count > 0
                        THEN
                           vpasexec := 7;

                           FOR j IN rie.beneficiario.benefesp.benefesp_gar(i)
                                    .benef_ident.first .. rie.beneficiario.benefesp.benefesp_gar(i)
                                                          .benef_ident.last
                           LOOP
                              vpasexec := 8;

                              --Ahora seleccionamos el beneidentificado que buscamos
                              IF rie.beneficiario.benefesp.benefesp_gar(i)
                               .benef_ident.exists(j)
                              THEN
                                 IF rie.beneficiario.benefesp.benefesp_gar(i).benef_ident(j)
                                  .norden = pnorden
                                 THEN
                                    RETURN rie.beneficiario.benefesp.benefesp_gar(i).benef_ident(j);
                                 END IF;
                              END IF;
                           END LOOP;
                        END IF;
                     END IF;
                  END IF;
               END LOOP;

               vpasexec := 9;
            END IF;
         END IF;
      END IF;

      vpasexec := 10;
      RETURN NULL;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_partriesbeneident_g;

   -- BUG19069:DRA:27/09/2011:Inici
   -- INI -IAXIS-10627 -21/01/2020
   FUNCTION f_partpolcorretaje(poliza   IN ob_iax_detpoliza,
		                           pnmovimi IN NUMBER DEFAULT NULL,
   -- FIN -IAXIS-10627 -21/01/2020
                               mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_corretaje IS
      corretaje t_iax_corretaje;
      vpasexec  NUMBER(8) := 1;
      vparam    VARCHAR2(500) := 'poliza='||poliza.npoliza||' pnmovimi='||pnmovimi; --IAXIS-10627 -21/01/2020
      vobject   VARCHAR2(200) := 'PAC_IOBJ_PROD.F_PartPolCorretaje';
      -- INI -IAXIS-10627 -21/01/2020
      e_object_error   EXCEPTION;
	    -- FIN -IAXIS-10627 -21/01/2020
   BEGIN
      IF poliza.corretaje IS NOT NULL
      THEN
         IF poliza.corretaje.count > 0
         THEN
           IF pnmovimi IS NULL THEN -- IAXIS-10627 -21/01/2020
             RETURN poliza.corretaje;
           -- INI -IAXIS-10627 -21/01/2020
           ELSE
             IF poliza.corretaje(poliza.corretaje.count).nmovimi != pnmovimi then
               corretaje := pac_md_obtenerdatos.f_leecorretaje(pnmovimi,mensajes);
               IF mensajes IS NOT NULL THEN
                 IF mensajes.COUNT > 0 THEN
                  vpasexec := 10;
                  RAISE e_object_error;
                 END IF;
               END IF;
               IF corretaje.count > 0 THEN
                 RETURN corretaje;
               ELSE
                 RETURN poliza.corretaje;
               END IF;
             ELSE
               RETURN poliza.corretaje;
             END IF;
           END IF;
           -- FIN -IAXIS-10627 -21/01/2020
         END IF;
      END IF;

      corretaje := t_iax_corretaje();
      RETURN corretaje;
   EXCEPTION
      -- INI -IAXIS-10627 -21/01/2020
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
      -- FIN -IAXIS-10627 -21/01/2020
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_partpolcorretaje;

   FUNCTION f_set_partcorretaje(poliza   IN OUT ob_iax_detpoliza,
                                corret   IN t_iax_corretaje,
                                mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_Set_PartCorretaje';
   BEGIN
      poliza.corretaje := corret;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_set_partcorretaje;

   -- BUG19069:DRA:27/09/2011:Fi

   /*************************************************************************
      Devuelve parte del objeto poliza a un objeto gestor cobros
      param in poliza       : objeto detalle póliza
      param in out mensajes : colección de mensajes
      return                : objeto colección gestor cobros
   *************************************************************************/
   -- Bug 0021592 - 08/03/2012 - JMF
   FUNCTION f_partpolgescobro(poliza   IN ob_iax_detpoliza,
                              mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_gescobros IS
      gesc     t_iax_gescobros;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.f_partpolgescobro';
   BEGIN
      IF poliza.gestorcobro IS NOT NULL
      THEN
         IF poliza.gestorcobro.count > 0
         THEN
            RETURN poliza.gestorcobro;
         END IF;
      END IF;

      gesc := t_iax_gescobros();
      RETURN gesc;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_partpolgescobro;

   --bfp bug 21947 ini
   FUNCTION f_partgaransegcom(riesgo   IN ob_iax_riesgos,
                              mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_garansegcom IS
      gsc      t_iax_garansegcom;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_partgaransegcom';
   BEGIN
      IF riesgo IS NOT NULL
      THEN
         IF riesgo.att_garansegcom IS NOT NULL
         THEN
            IF riesgo.att_garansegcom.count > 0
            THEN
               RETURN riesgo.att_garansegcom;
            END IF;
         END IF;
      END IF;

      gsc := t_iax_garansegcom();
      RETURN gsc;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_partgaransegcom;

   FUNCTION f_set_partgaransegcom(poliza   IN OUT ob_iax_detpoliza,
                                  pnriesgo IN riesgos.nriesgo%TYPE,
                                  pgsc     IN t_iax_garansegcom,
                                  mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_Set_partgaransegcom';
   BEGIN
      IF poliza.riesgos IS NOT NULL
      THEN
         IF poliza.riesgos.count > 0
         THEN
            vpasexec := 2;

            FOR i IN poliza.riesgos.first .. poliza.riesgos.last
            LOOP
               vpasexec := 3;

               IF poliza.riesgos.exists(i)
               THEN
                  vpasexec := 5;

                  IF poliza.riesgos(i).nriesgo = pnriesgo
                  THEN
                     vpasexec := 6;
                     poliza.riesgos(i).att_garansegcom := pgsc;
                     RETURN 0;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000646);
      RETURN 1;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_set_partgaransegcom;

   --bfp bug 21947 fi
   --  Ini Bug 21907 - MDS - 02/05/2012
   /*************************************************************************
      Sustituye el objeto primas de la prima determinada
      param in poliza       : objeto poliza
      param in prima        : objeto prima
      param in out mensajes : colección de mensajes
      return                : 0 todo correcto
                              1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_partprima(poliza   IN OUT ob_iax_detpoliza,
                            prima    IN ob_iax_primas,
                            mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_Set_PartPrima';
   BEGIN
      IF poliza.primas IS NOT NULL
      THEN
         vpasexec := 2;

         IF poliza.primas.count > 0
         THEN
            vpasexec := 3;

            -- bucle de 1 solo elemento
            FOR i IN poliza.primas.first .. poliza.primas.last
            LOOP
               vpasexec := 4;

               IF poliza.primas.exists(i)
               THEN
                  vpasexec := 5;
                  poliza.primas(i) := prima;
                  RETURN 0;
               END IF;
            END LOOP;
         END IF;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9903648);
      RETURN 1;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_set_partprima;

   --  Fin Bug 21907 - MDS - 02/05/2012
   -- BUG 21657 --ETM --04/06/2012
   FUNCTION f_set_partpolinquiaval(poliza    IN OUT ob_iax_detpoliza,
                                   pinquival IN t_iax_inquiaval,
                                   mensajes  IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.f_set_partpolinquiaval';
   BEGIN
      poliza.inquiaval := pinquival;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_set_partpolinquiaval;

   FUNCTION f_partpolinquiaval(poliza   IN ob_iax_detpoliza,
                               mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_inquiaval IS
      vinquival t_iax_inquiaval;
      vpasexec  NUMBER(8) := 1;
      vparam    VARCHAR2(1) := NULL;
      vobject   VARCHAR2(200) := 'PAC_IOBJ_PROD.F_Partpolinquival';
   BEGIN
      IF poliza.inquiaval IS NOT NULL
      THEN
         IF poliza.inquiaval.count > 0
         THEN
            RETURN poliza.inquiaval;
         END IF;
      END IF;

      vinquival := t_iax_inquiaval();
      RETURN vinquival;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_partpolinquiaval;

   --FIN BUG 21657--ETM-04/06/2012

   -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
   /*************************************************************************
      Devuelve parte del objeto poliza a un objeto coacuadro
      param in poliza       : objeto detalle póliza
      param in out mensajes : colección de mensajes
      return                : objeto colección tomadores
   *************************************************************************/
   FUNCTION f_partcoacuadro(poliza   IN ob_iax_detpoliza,
                            mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_coacuadro IS
      coacuadro ob_iax_coacuadro;
      vpasexec  NUMBER(8) := 1;
      vparam    VARCHAR2(1) := NULL;
      vobject   VARCHAR2(200) := 'PAC_IOBJ_PROD.f_partcoacuadro';
   BEGIN
      IF poliza.coacuadro IS NOT NULL
      THEN
         RETURN poliza.coacuadro;
      END IF;

      coacuadro := ob_iax_coacuadro();
      RETURN coacuadro;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_partcoacuadro;

   /*************************************************************************
      Sustituye el objeto COACUADRO
      param in poliza       : objeto riesgo
      param in coa          : objeto cuadro coaseguro
      param in out mensajes : colección de mensajes
      return                : 0 todo correcto
                              1 ha habido un error
   *************************************************************************/
   FUNCTION f_setpartcoacuadro(poliza   IN OUT ob_iax_detpoliza,
                               coa      IN ob_iax_coacuadro,
                               mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_Set_PartTomadores';
   BEGIN
      poliza.coacuadro := coa;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_setpartcoacuadro;

   -- Fin Bug 0023183

   -- Bug 0022701 - 03/09/2012 - JMF
   FUNCTION f_partpolretorno(poliza   IN ob_iax_detpoliza,
                             mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_retorno IS
      retorno  t_iax_retorno;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_PartPolRetorno';
   BEGIN
      IF poliza.retorno IS NOT NULL
      THEN
         IF poliza.retorno.count > 0
         THEN
            RETURN poliza.retorno;
         END IF;
      END IF;

      retorno := t_iax_retorno();
      RETURN retorno;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_partpolretorno;

   -- Bug 0022701 - 03/09/2012 - JMF
   FUNCTION f_set_partretorno(poliza   IN OUT ob_iax_detpoliza,
                              retrn    IN t_iax_retorno,
                              mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_Set_PartRetorno';
   BEGIN
      poliza.retorno := retrn;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_set_partretorno;

   --CONVENIOS
   /*************************************************************************
      Devuelve parte del objeto riesgo a un objeto aseguradosmes
      param in poliza       : objeto riesgo
      param in out mensajes : colección de mensajes
      return                : objeto colección de direcciones
   *************************************************************************/
   FUNCTION f_partaseguradosmes(riesgo   IN ob_iax_riesgos,
                                mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_aseguradosmes IS
      direc    ob_iax_aseguradosmes;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_partAseguradosMes';
   BEGIN
      IF riesgo IS NOT NULL
      THEN
         IF riesgo.aseguradosmes IS NOT NULL
         THEN
            --IF riesgo.riesdireccion.count > 0 THEN
            RETURN riesgo.aseguradosmes;
            --END IF;
         END IF;
      END IF;

      direc := ob_iax_aseguradosmes();
      RETURN direc;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_partaseguradosmes;

   --JRH 03/2008
   /*************************************************************************
      Sustituye el objeto aseguradosmes del riesgo determinado
      param in poliza       : objeto riesgo
      param in nriesgo      : número de riesgo
      param in pasegmes         : objeto segurados mes
      param in out mensajes : colección de mensajes
      return                : objeto colección preguntas
   *************************************************************************/
   FUNCTION f_set_partaseguradosmes(poliza   IN OUT ob_iax_detpoliza,
                                    nriesgo  IN riesgos.nriesgo%TYPE,
                                    pasegmes IN ob_iax_aseguradosmes,
                                    mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      riesgo   ob_iax_riesgos;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_Set_partaseguradosmes';
   BEGIN
      IF poliza.riesgos IS NOT NULL
      THEN
         IF poliza.riesgos.count > 0
         THEN
            vpasexec := 2;

            FOR i IN poliza.riesgos.first .. poliza.riesgos.last
            LOOP
               vpasexec := 3;

               IF poliza.riesgos.exists(i)
               THEN
                  vpasexec := 5;

                  IF poliza.riesgos(i).nriesgo = nriesgo
                  THEN
                     vpasexec := 6;
                     poliza.riesgos(i).aseguradosmes := pasegmes;
                     RETURN 0;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000646);
      RETURN 1;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_set_partaseguradosmes;

   /*************************************************************************
      Devuelve parte del objeto de versi??e una p??a
      param in poliza       : objeto p??a
      param in out mensajes : colección de mensajes
      return                : objeto colección de direcciones
   *************************************************************************/
   FUNCTION f_partconvempvers(poliza   IN ob_iax_detpoliza,
                              mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_convempvers IS
      direc    ob_iax_convempvers;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.f_partconvempvers';
   BEGIN
      IF poliza.convempvers IS NOT NULL
      THEN
         RETURN poliza.convempvers;
      END IF;

      direc := ob_iax_convempvers();
      RETURN direc;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_partconvempvers;

   /*************************************************************************
      Asocia parte del objeto poliza a un objeto versi??e convenio
      param in poliza       : objeto detalle póliza
      param in out mensajes : colección de mensajes
      return                : objeto colección clausulas
   *************************************************************************/
   FUNCTION f_set_partconvempvers(poliza       IN OUT ob_iax_detpoliza,
                                  pconvempvers IN ob_iax_convempvers,
                                  mensajes     IN OUT t_iax_mensajes,
                                  pmode        IN VARCHAR2 DEFAULT 'EST') -- Bug 18362 - APD - 01/06/2011
    RETURN NUMBER IS
      clau     t_iax_clausulas;
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_SET_PARTCONVEMPVERS';
      vnumerr  NUMBER;
      vpoliza  ob_iax_detpoliza;
   BEGIN
      poliza.convempvers := pconvempvers;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_set_partconvempvers;

   --CONVENIOS
   /*************************************************************************
      Devuelve parte del objeto poliza a un objeto citas medicas
      param in poliza       : objeto detalle póliza
      param in out mensajes : colección de mensajes
      return                : objeto colección citas medicas
   *************************************************************************/
   FUNCTION f_partpolcitamed(poliza   IN ob_iax_detpoliza,
                             mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_citamedica IS
      citamedicas t_iax_citamedica;
      vpasexec    NUMBER(8) := 1;
      vparam      VARCHAR2(1) := NULL;
      vobject     VARCHAR2(200) := 'PAC_IOBJ_PROD.F_PartPolCitaMed';
   BEGIN
      IF poliza.citamedicas IS NOT NULL
      THEN
         IF poliza.citamedicas.count > 0
         THEN
            RETURN poliza.citamedicas;
         END IF;
      END IF;

      citamedicas := t_iax_citamedica();
      RETURN citamedicas;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_partpolcitamed;

   /*************************************************************************
      Sustituye el objeto tomadores
      param in poliza       : objeto riesgo
      param in tom          : objeto tomadores
      param in out mensajes : colección de mensajes
      return                : 0 todo correcto
                              1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_partpolcitamed(poliza   IN OUT ob_iax_detpoliza,
                                 citas    IN t_iax_citamedica,
                                 mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(1) := NULL;
      vobject  VARCHAR2(200) := 'PAC_IOBJ_PROD.F_Set_PartTomadores';
   BEGIN
      poliza.citamedicas := citas;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_set_partpolcitamed;

   /*************************************************************************
      FUNCTION f_partpolcontgaran

      param in poliza    : ob_iax_detpoliza
      param in mensajes  : t_iax_mensajes
      return             : t_iax_contragaran
   *************************************************************************/
   FUNCTION f_partpolcontgaran(poliza   IN ob_iax_detpoliza,
                               mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_contragaran IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'pac_iobj_prod.f_partpolcontgaran';
      vparam   VARCHAR2(500);
      --
      v_contragaran t_iax_contragaran;
      vnum_err      NUMBER;
      --
   BEGIN
      --
      IF poliza.contragaran IS NOT NULL
      THEN
         IF poliza.contragaran.count > 0
         THEN
            RETURN poliza. contragaran;
         END IF;
      END IF;
      --
      v_contragaran := t_iax_contragaran();
      --
      RETURN v_contragaran;
      --
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_partpolcontgaran;

   /*************************************************************************
      FUNCTION f_set_partcontgaran

      param in poliza    : ob_iax_detpoliza
      contragaran        : t_iax_contragaran
      param in mensajes  : t_iax_mensajes
      return             : t_iax_contragaran
   *************************************************************************/
   FUNCTION f_set_partcontgaran(poliza    IN OUT ob_iax_detpoliza,
                                contgaran IN t_iax_contragaran,
                                mensajes  IN OUT t_iax_mensajes) RETURN NUMBER IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'pac_iobj_prod.f_set_partcontgaran';
      vparam   VARCHAR2(500);
      --
      vnum_err NUMBER;
      --
   BEGIN
      --
      poliza.contragaran := contgaran;
      --
      RETURN 0;
      --
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_set_partcontgaran;
END pac_iobj_prod;
/