--------------------------------------------------------
--  DDL for Package Body PAC_IAX_COBRADOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_COBRADOR" IS
       /******************************************************************************
      NOMBRE:       pac_iax_cobrador
      PROPÓSITO: Package para el mantenimiento de cobradores bancarios.

      REVISIONES:

      Ver        Fecha        Autor      Descripción
      ---------  ----------  ------      ------------------------------------
        1        29/09/2010   ICV        1. Creación del package
        2        22/09/2014   CASANCHEZ  2. 0032668: COLM004-Trapaso entre Bancos (cobrador bancario) manteniendo la nómina
   ******************************************************************************/

   /*****************************************************************************
        Función que selecciona todos los cobradores que cumplan con los parámetros de entrada de la consulta.
        PCEMPRES: Código de la empresa.
        PCCOBBAN: Número de cobrador.
        PCTIPBAN: Código tipo de cuenta
        PCDOMENT: Código de la Entidad
        PTSUFIJO: Sufijo asignado a la norma 19
        PCDOMSUC: Código Sucursal
        PCRAMO: Ramo
        PCMODALI: Modalidad
        PCCOLECT: Colectividad
        PCTIPSEG: Tipo de seguro
        PCAGENTE: Mediador
        PCBANCO: Código Banco
        param in out  : MENSAJES Missatges de sortida.
   *****************************************************************************/
   FUNCTION f_get_cobrador(
      pcempres IN NUMBER,
      pccobban IN NUMBER,
      pctipban IN NUMBER,
      pcdoment IN NUMBER,
      ptsufijo IN VARCHAR2,
      pcdomsuc IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcagente IN NUMBER,
      pcbanco IN NUMBER,
      pncuenta IN VARCHAR2,
      pcobrador OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_COBRADOR.F_GET_COBRADOR';
      vparam         VARCHAR2(500)
         := 'parámetros - PCEMPRES: ' || pcempres || ' - PCEMPRES: ' || pcempres
            || ' - PCCOBBAN: ' || pccobban || ' - PCTIPBAN: ' || pcempres || ' - PCDOMENT: '
            || pcdoment || ' - PTSUFIJO: ' || ptsufijo || ' - PCDOMSUC: ' || pcdomsuc
            || ' - PCRAMO: ' || pcramo || ' - PSPRODUC: ' || psproduc || ' - PCAGENTE: '
            || pcagente || ' - PCBANCO: ' || pcbanco || ' - PNCUENTA: ' || pncuenta;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_cobrador.f_get_cobrador(pcempres, pccobban, pctipban, pcdoment,
                                                ptsufijo, pcdomsuc, pcramo, psproduc,
                                                pcagente, pcbanco, pncuenta, pcobrador,
                                                mensajes);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

         IF pcobrador%ISOPEN THEN
            CLOSE pcobrador;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF pcobrador%ISOPEN THEN
            CLOSE pcobrador;
         END IF;

         RETURN 1;
   END f_get_cobrador;

   /*****************************************************************************
        Función que selecciona todos los cobradores que cumplan con los parámetros de entrada de la consulta.
        PCCOBBAN: Número de cobrador.
        param out  : MENSAJES Missatges de sortida.
   *****************************************************************************/
   FUNCTION f_get_cobrador_det(
      pccobban IN NUMBER,
      pobjban OUT t_iax_cobbancario,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_COBRADOR.F_GET_COBRADOR';
      vparam         VARCHAR2(500) := 'parámetros - pccobban: ' || pccobban;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      IF pccobban IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_cobrador.f_get_cobrador_det(pccobban, pobjban, mensajes);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_cobrador_det;

      /*****************************************************************************
        Función que selecciona la información de la selección del cobrador para uno en concreto.
        PCCOBBAN: Número de cobrador.
        param in out  : MENSAJES Missatges de sortida.
   *****************************************************************************/
   FUNCTION f_get_cobrador_sel(
      pccobban IN NUMBER,
      pnorden IN NUMBER,
      pccobbansel OUT t_iax_cobbancariosel,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000) := 'PCCOBBAN:' || pccobban;
      vobject        VARCHAR2(200) := 'PAC_IAX_COMISIONES.f_get_COBRADOR_SEL';
      verror         NUMBER;
   BEGIN
      IF pccobban IS NULL THEN
         RAISE e_param_error;
      END IF;

      verror := pac_md_cobrador.f_get_cobrador_sel(pccobban, pnorden, pccobbansel, mensajes);

      IF verror <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, ' ', 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_cobrador_sel;

   /*************************************************************************
       Nueva función que actualiza la información introducida o modificada del cobrador bancario.
       param pcempres    in : Código de la empresa.
       param PCCOBBAN    IN : Número de cobrador.
       param PCTIPBAN    IN : Código tipo de cuenta
       param PCDOMENT    IN : Código de la Entidad
       param PTSUFIJO    IN : Código Sucursal
       param PNCUENTA    IN : Número de cuenta
       param PCBAJA    IN : Código de baja
       param PCESCRIPCION    IN : Descripción
       param PNNUMNIF    IN : nif
       param CCONTABAN:  Código contable para el cobrador bancario
       param DOM_FILLER_LN3:  Filler para las líneas '3' del fichero de domiciliación
       retorno 0-Correcto, 1-Código error.
   *************************************************************************/
   FUNCTION f_set_cobrador(
      pccobban IN NUMBER,
      pncuenta IN VARCHAR2,
      ptsufijo IN VARCHAR2,
      pcempres IN NUMBER,
      pcdoment IN NUMBER,
      pcdomsuc IN NUMBER,
      pnprisel IN NUMBER,
      pcbaja IN NUMBER,
      pdescrip IN VARCHAR2,
      pnnumnif IN VARCHAR2,
      ptcobban IN VARCHAR2,
      pctipban IN NUMBER,
      pccontaban IN NUMBER,
      pdomfill3 IN VARCHAR2,
      pcmodo IN VARCHAR2,
      pprecimp IN NUMBER,
      pcagruprec IN NUMBER,   -- Bug 19986 - APD - 08/11/2011 - se añade el campo cagruprec
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_COBRADOR.f_set_cobrador';
      vparam         VARCHAR2(500)
         := 'parámetros - pccobban: ' || pccobban || ', pncuenta: ' || pncuenta
            || ' ptsufijo : ' || ptsufijo || ' pcempres : ' || pcempres || ' pcdoment : '
            || pcdoment || ' pcdomsuc : ' || pcdomsuc || ' pnprisel : ' || pnprisel
            || ' pnprisel : ' || pnprisel || ' pcbaja : ' || pcbaja || ' pdescrip : '
            || pdescrip || ' pnnumnif : ' || pnnumnif || ' ptcobban : ' || ptcobban
            || ' pctipban : ' || pctipban || ' pccontaban : ' || pccontaban || ' pdomfill3 : '
            || pdomfill3 || ' precimp :' || pprecimp || ' pcagruprec :' || pcagruprec;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      IF pccobban IS NULL
         OR pncuenta IS NULL
         OR ptsufijo IS NULL
         OR pcdoment IS NULL
         OR pcdomsuc IS NULL
         OR pnprisel IS NULL
         OR pctipban IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Falta especificar las validaciones
      -- Bug 19986 - APD - 08/11/2011 - se añade el campo cagruprec
      vnumerr := pac_md_cobrador.f_set_cobrador(pccobban, pncuenta, ptsufijo, pcempres,
                                                pcdoment, pcdomsuc, pnprisel, pcbaja, pdescrip,
                                                pnnumnif, ptcobban, pctipban, pccontaban,
                                                pdomfill3, pcmodo, pprecimp, pcagruprec,
                                                mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_cobrador;

   /*************************************************************************
       Nueva función que actualiza la información introducida o modificada del cobrador bancario.
       param PCCOBBAN    IN : Número de cobrador.
       param PNORDEN    in : Orden prioridad de selección
       param pcempres    in : Código de la empresa.
       param PCRAMO    IN : Ramo
       param PCMODALI    IN : Modalidad
       param PCTIPSEG    IN : Tipo de seguro
       param PCCOLECT    IN : Colectividad
       param PCBANCO    IN : Código Banco
       param PCTIPAGE    IN : Tipo mediador
       param PCAGENTE    IN :  Mediador
       retorno 0-Correcto, 1-Código error.
   *************************************************************************/
   FUNCTION f_set_cobrador_sel(
      pccobban IN NUMBER,
      pnorden IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcempres IN NUMBER,
      pcbanco IN NUMBER,
      pcagente IN NUMBER,
      pctipage IN NUMBER,
      pcmodo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_COBRADOR.f_set_cobrador_sel';
      vparam         VARCHAR2(500)
         := 'parámetros - pccobban: ' || pccobban || ', pNORDEN: ' || pnorden || ' pCRAMO : '
            || pcramo || ' pSproduc : ' || psproduc || ' pCEMPRES : ' || pcempres
            || ' pCBANCO : ' || pcbanco || ' pCAGENTE : ' || pcagente || ' pCTIPAGE : '
            || pctipage;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      IF pccobban IS NULL
         OR pnorden IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_cobrador.f_set_cobrador_sel(pccobban, pnorden, pcramo, psproduc,
                                                    pcempres, pcbanco, pcagente, pctipage,
                                                    pcmodo, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_cobrador_sel;

   /*************************************************************************
          Nueva función que retorna un número nuevo de cobrador
    ***************************************************************************/
   FUNCTION f_get_noucobrador(pccobban OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_COBRADOR.f_get_noucobrador';
      vparam         VARCHAR2(500) := 'parámetros -  ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_cobrador.f_get_noucobrador(pccobban, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_noucobrador;

   /*************************************************************************
     Nueva función que retorna la descripción de un banco
     retorno 0-Correcto, 1-Código error.
   *************************************************************************/
   FUNCTION f_get_desbanco(pcbanco IN NUMBER, ptbanco OUT VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_COBRADOR.f_get_desbanco';
      vparam         VARCHAR2(500) := 'parámetros -  pcbanco :' || pcbanco;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      IF pcbanco IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_cobrador.f_get_desbanco(pcbanco, ptbanco, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_desbanco;

   --
   -- Bug 0032668 Inicio - Se crea la nueva funcion f_traspaso_cobradores
   --
   /*************************************************************************
     Nueva función que reasliza el traspaso de bancos
     param pcempresa      IN  codigo de la empresa
     param pcobbanorigen  IN  cobrador bancario origen
     param pcbanco        IN  codigo de banco a trapasar
     param pcobbandestino IN  cobrador destino
     param mensajes       OUT mensaje de error
     retorno 0-Correcto, 1-Código error.
    *************************************************************************/
    --
   FUNCTION f_traspaso_cobradores(
      pcempresa IN empresas.cempres%TYPE,
      pcobbanorigen IN cobbancario.ccobban%TYPE,
      pcbanco IN bancos.cbanco%TYPE,
      pcobbandestino IN cobbancario.ccobban%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vobjectname    VARCHAR2(500) := 'PAC_IAX_COBRADOR.f_traspaso_cobradores';
      vparam         VARCHAR2(500) := 'parámetros -  pcbanco :' || pcbanco;
      --
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   --
   BEGIN
      --
      vnumerr := pac_md_cobrador.f_traspaso_cobradores(pcempresa => pcempresa,
                                                       pcobbanorigen => pcobbanorigen,
                                                       pcbanco => pcbanco,
                                                       pcobbandestino => pcobbandestino,
                                                       mensajes => mensajes);

      --
      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   --
   EXCEPTION
      WHEN e_param_error THEN
         --
         pac_iobj_mensajes.p_tratarmensaje(mensajes => mensajes, pfuncion => vobjectname,
                                           pnerror => 1000005, ptraza => vpasexec,
                                           pparams => vparam);
         --
         RETURN 1;
      --
      WHEN e_object_error THEN
         --
         pac_iobj_mensajes.p_tratarmensaje(mensajes => mensajes, pfuncion => vobjectname,
                                           pnerror => 1000006, ptraza => vpasexec,
                                           pparams => vparam);
         --
         RETURN 1;
      --
      WHEN OTHERS THEN
         --
         pac_iobj_mensajes.p_tratarmensaje(mensajes => mensajes, pfuncion => vobjectname,
                                           pnerror => 1000001, ptraza => vpasexec,
                                           pparams => vparam, psqcode => SQLCODE,
                                           psqerrm => SQLERRM);
         --
         RETURN 1;
   --
   END f_traspaso_cobradores;
--
-- Bug 0032668 Fin
--
END pac_iax_cobrador;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_COBRADOR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_COBRADOR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_COBRADOR" TO "PROGRAMADORESCSI";
