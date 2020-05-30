--------------------------------------------------------
--  DDL for Package Body PAC_MD_REHABILITA
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY PAC_MD_REHABILITA AS
   /******************************************************************************
     NOMBRE:     PAC_MD_REHABILITA
     PROPÓSITO:  Package para gestionar los MAPS

     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        11/05/2009   ICV               1. Creación del package. Bug.: 9784
     2.0        12/01/2010   DRA               2. 0010093: CRE - Afegir filtre per RAM en els cercadors
     3.0        23/02/2010   LCF               3. 0009605: BUSCADORS - Afegir matricula,cpostal,desc
     4.0        31/01/2013   DCT               4. 0025628: LCOL_T031-LCOL - AUT - (ID 278 id 85) Control duplicidad matriculas
     5.0        27/02/2014   AGG               5. 0030356: Al intentar rehabilitar cualquier p�liza aparece el siguiente mensaje "Registro no encontrado
     6.0        01/07/2015   IGIL              6. 0035888/203837 quitar UPPER a NNUMNIF
     7.0        29/05/2019   ECP               7. IAXIS-3592. PRoceso de Terminaci�n por no pago.
   ******************************************************************************/

   /*************************************************************************
          FUNCTION F_GET_polizasanul
          Función que recuperará pólizas anuladas y vencidas dependiendo de los parámetros de entrada.
          param in Psproduc: Number. Código de producto.
          param in Pnpoliza: Number. nº de póliza.
          param in Pncertif: Number. nº de certificado.
          param in Pnnumide: Varchar2. NIF/CIF del tomador/asegurado
          param in Pbuscar: VARCHAR2.  nombre del tomador/asegurado.
          param in Psnip: VARCHAR2.  código terceros del tomador/asegurado
          param in Ptipopersona: Number.  Determina si búsqueda por tomador o asegurado
          param in Pcagente : NUMBER.  Código del agente
          param in Pcramo:  NUMBER   Código del ramo
          param in T_IAX_MENSAJES. Tipo t_iax_mensajes. Parámetro de Entrada / Salida. Mensaje de error
          return             : Devolverá un number con el error producido.
                               0 en caso de que haya ido correctamente.
     *************************************************************************/
   FUNCTION f_get_polizasanul(
      psproduc IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pnnumide IN VARCHAR2,
      pbuscar IN VARCHAR2,
      psnip IN VARCHAR2,
      ptipopersona IN NUMBER,
      pcmatric IN VARCHAR2,   --BUG19605:LCF:19/02/2010
      pcpostal IN VARCHAR2,   --BUG19605:LCF:19/02/2010
      ptdomici IN VARCHAR2,   --BUG19605:LCF:19/02/2010
      ptnatrie IN VARCHAR2,   --BUG19605:LCF:19/02/2010
      pcagente IN NUMBER,   -- BUG10093:DRA:12/01/2010
      pcramo IN NUMBER,   -- BUG10093:DRA:12/01/2010
      pcpolcia IN VARCHAR2,
      pccompani IN NUMBER,
      pcactivi IN NUMBER,
      pfilage IN NUMBER,
      mensajes IN OUT t_iax_mensajes,
      pcsucursal IN NUMBER DEFAULT NULL,   -- Bug 22839/126886 - 29/10/2012 - AMC
      pcadm IN NUMBER DEFAULT NULL,   -- Bug 22839/126886 - 29/10/2012 - AMC
      pcmotor IN VARCHAR2 DEFAULT NULL,   -- BUG25177/132998:JLTS:18/12/2012
      pcchasis IN VARCHAR2 DEFAULT NULL,   -- BUG25177/132998:JLTS:18/12/2012
      pnbastid IN VARCHAR2 DEFAULT NULL   -- BUG25177/132998:JLTS:18/12/2012
                                       )
      RETURN sys_refcursor IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros - psproduc = ' || psproduc || ' pnpoliza = ' || pnpoliza
            || ' pncertif = ' || pncertif || ' pnnumide = ' || pnnumide || ' pbuscar = '
            || pbuscar || ' psnip = ' || psnip || ' ptipopersona = ' || ptipopersona
            || ' pcagente = ' || pcagente || ' pcramo = ' || pcramo;
      vobject        VARCHAR2(200) := 'PAC_MD_REHABILITA.f_get_polizasanul';
      vsquery        VARCHAR2(4000);
      v_cidioma      idiomas.cidioma%TYPE;
      vcursor        sys_refcursor;
      num_err        NUMBER := 0;
   BEGIN
      --Comprovem els paràmetres d'entrada.
      IF pnnumide IS NOT NULL
         OR pbuscar IS NOT NULL THEN
         IF ptipopersona IS NULL THEN
            RAISE e_param_error;
         END IF;
      END IF;

      vpasexec := 2;
      --Busquem l'idioma.
      v_cidioma := pac_md_common.f_get_cxtidioma;
      vpasexec := 3;
      num_err := pac_rehabilita.f_get_polizasanul(psproduc, pnpoliza, pncertif, pnnumide,
                                                  pbuscar, psnip, ptipopersona, v_cidioma,
                                                  pcmatric, pcpostal, ptdomici, ptnatrie,
                                                  pcagente, pcramo, pcpolcia, pccompani,
                                                  pcactivi, pac_md_common.f_get_cxtempresa,
                                                  pac_md_common.f_get_cxtagente, pfilage,
                                                  vsquery, pcsucursal, pcadm,   -- Bug 22839/126886 - 29/10/2012 - AMC
                                                  pcmotor,   -- BUG25177/132998:JLTS:18/12/2012
                                                  pcchasis,   -- BUG25177/132998:JLTS:18/12/2012
                                                  pnbastid   -- BUG25177/132998:JLTS:18/12/2012
                                                          );

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      vpasexec := 4;
      vcursor := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 5;
      num_err := pac_md_log.f_log_consultas(vsquery, 'PAC_MD_REHABILITA.F_GET_POLIZASANUL', 2,
                                            0, mensajes);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_polizasanul;

   /*************************************************************************
          FUNCTION F_get_fsuplem
          Función que recuperará la fecha de efecto del último suplemento realizado a la póliza.
          param in Psseguro: Number. Identificador del Seguro.
          param in T_IAX_MENSAJES. Tipo t_iax_mensajes. Parámetro de Entrada / Salida. Mensaje de error
          return             : Date en caso correcto
                               Nulo en caso incorrecto
     *************************************************************************/
   FUNCTION f_get_fsuplem(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN DATE IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000) := 'parámetros - psseguro = ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_MD_REHABILITA.f_get_fsuplem';
      vsquery        VARCHAR2(400);
      num_err        NUMBER := 0;
      v_fsuplem      DATE;
   BEGIN
      --Comprovem els paràmetres d'entrada.
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_fsuplem := pac_rehabilita.f_get_fsuplem(psseguro);

      IF v_fsuplem IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001566);
         RAISE e_object_error;
      END IF;

      RETURN v_fsuplem;
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
   END f_get_fsuplem;

   /*************************************************************************
          FUNCTION F_get_motanul
          Función que recuperará la descripción del motivo de anulación de la póliza.
          param in T_IAX_MENSAJES. Tipo t_iax_mensajes. Parámetro de Entrada / Salida. Mensaje de error
          param in Psseguro: Number. Identificador del Seguro.
          return             : Devuelve un varchar con el motivo de anulación en caso correcto
                               Nulo en caso incorrecto
     *************************************************************************/
   FUNCTION f_get_motanul(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000) := 'parámetros - psseguro = ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_MD_REHABILITA.f_get_motanul';
      vsquery        VARCHAR2(400);
      num_err        NUMBER := 0;
      v_cidioma      idiomas.cidioma%TYPE;
      v_tmotmov      motmovseg.tmotmov%TYPE;
   BEGIN
      --Comprovem els paràmetres d'entrada.
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      --Busquem l'idioma.
      v_cidioma := pac_md_common.f_get_cxtidioma;
      vpasexec := 3;
      v_tmotmov := pac_rehabilita.f_get_motanul(psseguro, v_cidioma);

      IF v_tmotmov IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 151371);
         RAISE e_object_error;
      END IF;

      RETURN v_tmotmov;
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
   END f_get_motanul;

   /*************************************************************************
        FUNCTION F_rehabilitapol
        Función que realizará la rehabilitación de una póliza.
        param in Psseguro: Number. Identificador del Seguro.
        param in pcmotmov: Number. motivo del movimiento.
        param in panula_extorn: Number.
        param in T_IAX_MENSAJES. Tipo t_iax_mensajes. Parámetro de Entrada / Salida. Mensaje de error
        return             : Un cero si todo ha ido bien y el código de error en caso contrario.
   *************************************************************************/
   -- Bug 26151 - APD - 26/02/2013 - se a�ade el parametro ptratar_recibo que indicara si no se debe
   -- realizar nada con los recibos (0) o seguir realizando lo que se hace hasta ahora con los recibos (1)
   FUNCTION f_rehabilitapol(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      panula_extorn IN NUMBER,
      mensajes IN OUT t_iax_mensajes,
      ptratar_recibo IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros - psseguro = ' || psseguro || ' pcmotmov : ' || pcmotmov
            || ' panula_extorn : ' || panula_extorn || ' ptratar_recibo : ' || ptratar_recibo;
      vobject        VARCHAR2(200) := 'PAC_MD_REHABILITA.f_rehabilitapol';
      vsquery        VARCHAR2(400);
      num_err        NUMBER := 0;
      v_err          NUMBER;
      v_xnrecibo     NUMBER;
      v_texto        VARCHAR2(100);
      vbloqueo       NUMBER;
      vcobjase       NUMBER;
      vcmatric       VARCHAR2(12);
      vnbastid       VARCHAR2(20);
      vcodmotor      VARCHAR2(100);
      vsproduc       NUMBER;
      vfefecto       DATE;
      v_valida_duplicidad NUMBER;
      vcertif        seguros.ncertif%TYPE;
   BEGIN
      --Comprovem els paràmetres d'entrada.
      IF psseguro IS NULL
         OR pcmotmov IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Miramos si la persona esta bloqueada por LOPD. Ya sea tomador, asegurado, riesgo, benficiario o en figuras de siniestros
      --0021813#XPL25042012
      vbloqueo := NVL(pac_persona.f_esta_persona_bloqueada(psseguro,
                                                           pac_md_common.f_get_cxtagente),
                      0);

      IF vbloqueo = 0 THEN
         vpasexec := 2;

         --BUG 0025628 INICIO - DCT - 31/01/2013
         BEGIN
            SELECT s.cobjase, a.cmatric, a.nbastid, a.codmotor, s.sproduc, s.fefecto
              INTO vcobjase, vcmatric, vnbastid, vcodmotor, vsproduc, vfefecto
              FROM seguros s, autriesgos a
             WHERE s.sseguro = a.sseguro
               AND s.sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               vcobjase := 0;
         END;

         --Veh�culo
         IF vcobjase = 5 THEN
            num_err := pac_autos.f_controlduplicidad(psseguro, vcmatric, vnbastid, vcodmotor,
                                                     vsproduc, vfefecto, NULL, 'POL');

            IF num_err <> 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
               RAISE e_object_error;
            END IF;
         END IF;

         --BUG 29011/163810 - RCL - 0029011: LCOL_A004-Qtracker: 0010100: ERROR CESION DE POLIZAS
         vpasexec := 3;

         BEGIN
            SELECT ncertif
              INTO vcertif
              FROM seguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vcertif := 0;
         END;

         --BUG 0030356/0167826 27/02/2014 AGG
         IF ((NVL(f_parproductos_v(vsproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
              AND vcertif <> 0))
            OR(NVL(f_parproductos_v(vsproduc, 'ADMITE_CERTIFICADOS'), 0) = 0) THEN
            num_err := pac_rehabilita.f_reaseguro(psseguro, v_err);
         END IF;

         IF num_err <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
            RAISE e_object_error;
         END IF;

         --BUG 0025628 FIN - DCT - 31/01/2013
         vpasexec := 4;
         -- Bug 26151 - APD - 26/02/2013 - se a�ade el parametro ptratar_recibo
         num_err := pac_rehabilita.f_ejecuta(psseguro, NULL, pcmotmov, panula_extorn,
                                             v_xnrecibo, ptratar_recibo);

         -- fin Bug 26151 - APD - 26/02/2013
         IF num_err <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
            RAISE e_object_error;
         END IF;

         v_texto := f_axis_literales(9001825, pac_md_common.f_get_cxtidioma);
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 0, v_texto);
      ELSE
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9903627);
         RETURN 1;
      END IF;

      RETURN NVL(num_err, 0);
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
   END f_rehabilitapol;

   /*************************************************************************
          FUNCTION F_get_pregunta
          Función que recuperará el literal de la pregunta.
          param in Psseguro: Number. Identificador del Seguro.
          param in T_IAX_MENSAJES. Tipo t_iax_mensajes. Parámetro de Entrada / Salida. Mensaje de error
          return             : Devuelve un varchar con la pregunta
                                    1.- Se han encontrado extornos en estado pendiente, desea anularlos?
                                    2.- Se han encontrado extornos en estado cobrado, desea descobrarlos y anularlos?
     *************************************************************************/
   FUNCTION f_get_pregunta(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000) := 'parámetros - psseguro = ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_MD_REHABILITA.f_get_pregunta';
      vsquery        VARCHAR2(400);
      num_err        NUMBER := 0;
      v_preg         NUMBER;
      v_ttexto       VARCHAR2(200);
   BEGIN
      --Comprovem els paràmetres d'entrada.
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_preg := pac_rehabilita.f_pregunta(psseguro);
      vparam := vparam||' v_preg-->'||v_preg;

      IF v_preg IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001823);
         RAISE e_object_error;
      END IF;

      vpasexec := 3;
-- Ini IAXIS-3592  -- ECP -- 29/05/2019
      IF v_preg = 1 THEN
         v_ttexto := f_axis_literales(180329, pac_md_common.f_get_cxtidioma);
      ELSIF v_preg = 2 THEN
         v_ttexto := f_axis_literales(180331, pac_md_common.f_get_cxtidioma);
      ELSIF nvl(v_preg,0) = 0 THEN
         v_ttexto := NULL;
      ELSE
         v_ttexto := NULL;
      END IF;
-- Fin IAXIS-3592  -- ECP -- 29/05/2019
      vpasexec := 4;
      RETURN v_ttexto;
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
   END f_get_pregunta;

   -- BUG 19276 Reemplazos jbn
    /*************************************************************************
       FUNCTION   F_VALIDA_REHABILITA
       validaciones necesarias para determinar si una póliza anulada se puede rehabilitar
        param in Psseguro: Number.   Identificador del Seguro.
              in Pnmovimi: Number.   Movimiento de rehabilitacion
              in Pcagente: Varchar2. Codigo de Agente
        return           : 0 en caso correcto
                                  error en caso contrario
   *************************************************************************/
   --Ini IAXIS-3592 -- ECP -- 29/05/2019
   FUNCTION f_valida_rehabilita(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000) := 'parámetros - psseguro = ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_MD_REHABILITA.f_get_pregunta';
      vsquery        VARCHAR2(400);
      num_err        NUMBER := 0;
      v_preg         NUMBER;
      v_ttexto       VARCHAR2(200);
   BEGIN
      --Comprovem els paràmetres d'entrada.
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      num_err := pac_rehabilita.f_valida_rehabilita(psseguro);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      vpasexec := 4;
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
   END f_valida_rehabilita;
--Fin IAXIS-3592 -- ECP -- 29/05/2019
   FUNCTION f_set_solrehab(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pnriesgo IN NUMBER,
      pfrehab IN DATE,
      ptobserv IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
      v_nmovimi      NUMBER;
      vcmotmov       NUMBER;
      v_dummy        NUMBER := 0;
      wnorden        NUMBER;
      wnpoliza       NUMBER;
      pcclagd        NUMBER;
      ptclagd        VARCHAR2(100);
      vidapunte      NUMBER;
      vobject        VARCHAR2(200) := 'PAC_MD_REHABILITA.f_set_solrehab';
      v_cagente      NUMBER;
      v_ctipage      NUMBER;
      v_cempres      NUMBER;
      vcidioma       NUMBER;
      xfanulac       DATE;
      wcmovseg       NUMBER;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(200) := '';
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      num_err := pac_rehabilita.f_set_solrehab(psseguro, pcmotmov, pnriesgo, pfrehab, ptobserv);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      ELSE
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 1000405);
      END IF;

      RETURN num_err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1000001;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1000001;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1000001;
   END f_set_solrehab;
END pac_md_rehabilita;

/