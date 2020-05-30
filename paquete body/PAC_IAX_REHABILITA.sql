--------------------------------------------------------
--  DDL for Package Body PAC_IAX_REHABILITA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_REHABILITA" AS
   /******************************************************************************
     NOMBRE:       PAC_IAX_REHABILITA
     PROPÓSITO:  Package para gestionar las Rehabilitaciones

     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        11/05/2009   ICV                1. Creación del package. Bug.: 9784
     2.0        12/01/2010   DRA                2. 0010093: CRE - Afegir filtre per RAM en els cercadors
     3.0        23/02/2010   LCF                3. 0009605: BUSCADORS - Afegir matricula,cpostal,desc
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
        param OUT T_IAX_MENSAJES. Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error
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
      mensajes OUT t_iax_mensajes,
      pcsucursal IN NUMBER DEFAULT NULL,   -- Bug 22839/126886 - 29/10/2012 - AMC
      pcadm IN NUMBER DEFAULT NULL,   -- Bug 22839/126886 - 29/10/2012 - AMC
      pcmotor IN VARCHAR2,   -- BUG25177/132998:JLTS:18/12/2012
      pcchasis IN VARCHAR2,   -- BUG25177/132998:JLTS:18/12/2012
      pnbastid IN VARCHAR2   -- BUG25177/132998:JLTS:18/12/2012
                          )
      RETURN sys_refcursor IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros - psproduc = ' || psproduc || ' pnpoliza = ' || pnpoliza
            || ' pncertif = ' || pncertif || ' pnnumide = ' || pnnumide || ' pbuscar = '
            || pbuscar || ' psnip = ' || psnip || ' ptipopersona = ' || ptipopersona
            || ' pcagente = ' || pcagente || ' pcramo = ' || pcramo || ' pfilage = '
            || pfilage;
      vobject        VARCHAR2(200) := 'PAC_IAX_REHABILITA.f_get_polizasanul';
      vcursor        sys_refcursor;
   BEGIN
      vpasexec := 2;
      vcursor :=
         pac_md_rehabilita.f_get_polizasanul(psproduc, pnpoliza, pncertif, pnnumide, pbuscar,
                                             psnip, ptipopersona, pcmatric, pcpostal,
                                             ptdomici, ptnatrie, pcagente, pcramo, pcpolcia,
                                             pccompani, pcactivi, pfilage, mensajes,
                                             pcsucursal, pcadm,   -- Bug 22839/126886 - 29/10/2012 - AMC
                                             pcmotor,   -- BUG25177/132998:JLTS:18/12/2012
                                             pcchasis,   -- BUG25177/132998:JLTS:18/12/2012
                                             pnbastid   -- BUG25177/132998:JLTS:18/12/2012
                                                     );
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
   FUNCTION f_get_fsuplem(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN DATE IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000) := 'parámetros - psseguro = ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_iax_rehabilita.f_get_fsuplem';
      vsquery        VARCHAR2(400);
      num_err        NUMBER := 0;
      v_fsuplem      DATE;
   BEGIN
      --Comprovem els parametres d'entrada.
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      RETURN pac_md_rehabilita.f_get_fsuplem(psseguro, mensajes);
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
          param in Psseguro: Number. Identificador del Seguro.
          param in T_IAX_MENSAJES. Tipo t_iax_mensajes. Parámetro de Entrada / Salida. Mensaje de error
          return             : Devuelve un varchar con el motivo de anulación en caso correcto
                               Nulo en caso incorrecto
     *************************************************************************/
   FUNCTION f_get_motanul(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000) := 'parámetros - psseguro = ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_iax_rehabilita.f_get_motanul';
      vsquery        VARCHAR2(400);
      num_err        NUMBER := 0;
   BEGIN
      --Comprovem els parametres d'entrada.
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      RETURN pac_md_rehabilita.f_get_motanul(psseguro, mensajes);
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
        return             : Un cero si todo ha ido
                             Un 1 en caso contrario
   *************************************************************************/
   FUNCTION f_rehabilitapol(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      panula_extorn IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros - psseguro = ' || psseguro || ' pcmotmov = ' || pcmotmov
            || ' panula_Exotrn = ' || panula_extorn;
      vobject        VARCHAR2(200) := 'PAC_iax_rehabilita.f_get_rehabilitapol';
      vsquery        VARCHAR2(400);
      num_err        NUMBER := 0;
   BEGIN
      --Comprovem els parametres d'entrada.
      IF psseguro IS NULL
         OR pcmotmov IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      num_err := pac_md_rehabilita.f_rehabilitapol(psseguro, pcmotmov, panula_extorn, mensajes);

      IF num_err = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
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
   FUNCTION f_get_pregunta(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000) := 'parámetros - psseguro = ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_iax_rehabilita.f_get_pregunta';
      vsquery        VARCHAR2(400);
      num_err        NUMBER := 0;
   BEGIN
      --Comprovem els parametres d'entrada.
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      RETURN pac_md_rehabilita.f_get_pregunta(psseguro, mensajes);
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
   FUNCTION f_valida_rehabilita(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(2000) := 'parámetros - psseguro = ' || psseguro;
      -- BUG: 26570 08/04/2013  amj
      --vobject        VARCHAR2(200) := 'PAC_MD_REHABILITA.f_get_pregunta';
      vobject        VARCHAR2(200) := 'PAC_MD_REHABILITA.f_valida_rehabilita';
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
      num_err := pac_md_rehabilita.f_valida_rehabilita(psseguro, mensajes);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

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
   END f_valida_rehabilita;

   FUNCTION f_set_solrehab(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pnriesgo IN NUMBER,
      pfrehab IN DATE,
      ptobserv IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
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
      vobject        VARCHAR2(200) := 'PAC_IAX_REHABILITA.f_set_solrehab';
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

      num_err := pac_md_rehabilita.f_set_solrehab(psseguro, pcmotmov, pnriesgo, pfrehab,
                                                  ptobserv, mensajes);
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
END pac_iax_rehabilita;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_REHABILITA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_REHABILITA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_REHABILITA" TO "PROGRAMADORESCSI";
