--------------------------------------------------------
--  DDL for Package Body PAC_IAX_TRASPASOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_TRASPASOS" AS
   /******************************************************************************
     NOMBRE::       PAC_IAX_traspasos
     PROPÓSITO:  Package para gestionar los traspasosS

     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        06/05/2009   ICV                1. Creación del package. Bug.: 9940
     2.0        14/07/2010   SRA                2. 0015372: CEM210 - Errores en grabación y gestión de traspasos de salida
     3.0        06/10/2010   SRA                3. 0016215: ANUL·LACIÓ TRASPASSOS
     4.0        20/10/2010   SRA                4. 0016259: HABILITAR CAMPOS DE TEXTO ESP0ECÍFICOS PARA TRASPASOS DERECHOS ECONÓMICOS
     5.0        10/01/2012   JMF                5. 0020856: ENSA800 - Controlar importe traspaso de SALIDA parcial
   ******************************************************************************/

   /*************************************************************************
          FUNCTION f_get_dattraspasos
          Función para devolver los campos descriptivos de un traspasos.
          param in Ptraspasos: Tipo carácter. Id. del traspasos.
          param out MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error
          return             : Retorna un sys_refcursor con los campos descriptivos de un traspasos.
      *************************************************************************/
      /*************************************************************************
      FUNCTION F_GET_TRASPASOS
      Función que sirve para recuperar una colección de traspasos.
           PSPRODUC: Tipo numérico. Parámetro de entrada. Código de producto.
           PFILTROPROD: Tipo carácter. Parámetro de entrada. Valor 'TRASPASO'.
           NPOLIZA: Tipo numérico. Parámetro de entrada. Id. de póliza.
           NCERTIF: Tipo numérico. Parámetro de entrada. Id. de certificado
           PNNUMNIDE: Tipo carácter. Parámetro de entrada. Documento.
           PBUSCAR: Tipo carácter. Parámetro de entrada. Nombre de la persona.
           PTIPOPERSONA: Tipo numérico. Parámetro de entrada. Indica si buscamos por Tomador o Asegurado
           PSNIP: Tipo carácter. Parámetro de entrada. Número d'identificador.
           PCINOUT: Tipo numérico. Parámetro de entrada. Traspasos de entrada o salida
           PCESTADO: Tipo numérico. Parámetro de entrada. Indica el estado.
           PFSOLICI: Tipo fecha. Parámetro de entrada. Fecha solicitud.
           PCTIPTRAS: Tipo numérico. Parámetro de entrada. Total o Parcial
           PCTIPTRASSOL: Tipo numérico. Parámetro de entrada. Tipo importe Potser sobra o millor algun altre paràmetre com PCTIPDER.
           MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.
   Retorna una colección T_IAX_TRASPASOS.
       *************************************************************************/
   FUNCTION f_get_traspasos(
      psproduc IN NUMBER,   -- Código de producto
      cramo IN NUMBER,   -- Código de ramo
      pfiltroprod IN VARCHAR2,   -- Valor ‘TRASPASO’
      npoliza IN NUMBER,   -- Id  de póliza
      ncertif IN NUMBER,   -- Id  de certificado
      pnnumnide IN VARCHAR2,   -- Documento
      pbuscar IN VARCHAR2,   -- Nombre de la persona
      ptipopersona IN NUMBER,   -- Indica si buscamos por Tomador o Asegurado
      psnip IN VARCHAR2,   -- Número d’identificador
      pcinout IN NUMBER,   -- Traspasos de entrada o salida
      pcestado IN NUMBER,   -- Indica el estado
      pfsolici IN DATE,   -- Fecha solicitud
      pctiptras IN NUMBER,   -- Total o Parcial
      pctiptrassol IN NUMBER,   -- Tipo importe
      pmodo IN VARCHAR2,   -- Mode amb que es entra a fer traspasos (Anulacio, revocació, solicitud...)
      mensajes OUT t_iax_mensajes   -- Mensaje de error
                                 )
      RETURN t_iax_traspasos IS
      v_result       t_iax_traspasos;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros - psproduc:' || TO_CHAR(psproduc) || 'pfiltroprod:' || pfiltroprod
            || 'npoliza:' || TO_CHAR(npoliza) || 'ncertif:' || TO_CHAR(ncertif)
            || 'pnnumnide:' || pnnumnide;   --Solo los obligatorios
      vobject        VARCHAR2(200) := 'PAC_IAX_traspasos.F_GET_TRASPASOS';
      v_fich         VARCHAR2(400);
   BEGIN
      vpasexec := 1;
      /*--Comprovem els parametres d'entrada.
      IF psproduc IS NULL
         OR pfiltroprod IS NULL
         OR npoliza IS NULL
         OR ncertif IS NULL
         OR pnnumnide IS NULL THEN
         RAISE e_param_error;
      END IF;*/
      vpasexec := 2;
      v_result := pac_md_traspasos.f_get_traspasos(psproduc, cramo, pfiltroprod, npoliza,
                                                   ncertif, pnnumnide, pbuscar, ptipopersona,
                                                   psnip, pcinout, pcestado, pfsolici,
                                                   pctiptras, pctiptrassol, pmodo, mensajes);
      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN v_result;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN v_result;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_result;
   END f_get_traspasos;

   /*************************************************************************
   FUNCTION F_GET_TRASPASO
   Función que sirve para recuperar una colección de un traspaso.
        PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
        MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.
   Retorna una colección T_IAX_TRASPASOS con UN SOLO TRAPASO
    *************************************************************************/
   FUNCTION f_get_traspaso(pstras IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN ob_iax_traspasos IS
      v_result       ob_iax_traspasos := ob_iax_traspasos();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pstras = ' || pstras;
      vobject        VARCHAR2(200) := 'PAC_IAX_traspasos.f_get_traspaso';
      v_fich         VARCHAR2(400);
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF pstras IS NULL THEN
         RETURN ob_iax_traspasos();
      -- RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_result := pac_md_traspasos.f_get_traspaso(pstras, mensajes);
      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN v_result;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN v_result;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_result;
   END f_get_traspaso;

/*************************************************************************
FUNCTION F_SET_TRASPASO
Función que sirve para insertar o actualizar datos del traspaso. Sólo se puede utilizar si el traspaso esta en estado Sin confirmar o Confirmado.

Retorna un valor numérico: 0 si ha grabado el traspaso y 1 si se ha producido algún error.
*************************************************************************/
   FUNCTION f_set_traspaso(
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pcagrpro IN NUMBER,
      pfsolici IN DATE,
      pcinout IN NUMBER,
      pctiptras IN NUMBER,
      pcextern IN NUMBER,
      pctipder IN NUMBER,
      pcestado IN NUMBER,
      pctiptrassol IN NUMBER,
      piimptemp IN NUMBER,
      nporcen IN NUMBER,
      nparpla IN NUMBER,
      ccodpla IN NUMBER,
      tccodpla IN VARCHAR2,
      ccompani IN NUMBER,
      tcompani IN VARCHAR2,
      ctipban IN NUMBER,
      cbancar IN VARCHAR2,
      tpolext IN VARCHAR2,
      ncertext IN NUMBER,
      fantigi IN DATE,
      iimpanu IN NUMBER,
      nparret IN NUMBER,
      iimpret IN NUMBER,   --es en realidad iimporte.
      nparpos2006 IN NUMBER,
      porcpos2006 IN NUMBER,
      nparant2007 IN NUMBER,
      porcant2007 IN NUMBER,
      tmemo IN VARCHAR2,
      nref IN VARCHAR2,
      cmotivo IN NUMBER,
      fefecto IN DATE,
      fvalor IN DATE,
      pstras IN NUMBER,
-- Ini Bug 16259 - SRA - 20/10/2010: nuevos campos en la pantalla axisctr093
      pctipcont IN NUMBER,
      pfcontig IN DATE,
      pctipcap IN NUMBER,
      pimporte IN NUMBER,
      pfpropag IN DATE,
-- Fin Bug 16259 - SRA - 20/10/2010
      pstras_out OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER(1) := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros - psproduc:' || psproduc || 'psseguro:' || psseguro || 'npcagrpro:'
            || pcagrpro || 'pfsolici:' || TO_CHAR(pfsolici, 'dd/mm/yyyy') || 'pcinout:'
            || pcinout || ' ... y más';
      vobject        VARCHAR2(200) := 'PAC_IAX_traspasos.F_SET_TRASPASO';
      v_fich         VARCHAR2(400);
      v_stras        trasplainout.stras%TYPE := pstras;
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF psseguro IS NULL
         OR pfsolici IS NULL
         OR pcinout IS NULL
         OR pctiptras IS NULL
         OR pctipder IS NULL
         OR pcestado IS NULL
         OR(pctiptras = 2
            AND pctiptrassol IS NULL)
         OR(pctiptras = 2
            AND piimptemp IS NULL
            AND nporcen IS NULL
            AND nparpla IS NULL) THEN
         RAISE e_param_error;
      END IF;

      IF ccodpla IS NULL
         AND ccompani IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9900995);
         RETURN -1;
      END IF;

      vpasexec := 2;
      v_result := pac_md_traspasos.f_set_traspaso(psseguro, psproduc, pcagrpro, pfsolici,
                                                  pcinout, pctiptras, pcextern, pctipder,
                                                  pcestado, pctiptrassol, piimptemp, nporcen,
                                                  nparpla, ccodpla, tccodpla, ccompani,
                                                  tcompani, ctipban, cbancar, tpolext,
                                                  ncertext, fantigi, iimpanu, nparret, iimpret,
                                                  nparpos2006, porcpos2006, nparant2007,
                                                  porcant2007, tmemo, nref, cmotivo, fefecto,
                                                  fvalor,
                                                  -- Ini Bug 16259 - SRA - 20/10/2010: nuevos campos en la pantalla axisctr093
                                                  pctipcont, pfcontig, pctipcap, pimporte,
                                                  pfpropag,
                                                  -- Fin Bug 16259 - SRA - 20/10/2010
                                                  v_stras, mensajes);
      pstras_out := v_stras;

      IF v_result = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 109904);
      ELSE
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000455);
      END IF;

      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN v_result;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN v_result;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_result;
   END f_set_traspaso;

      /*************************************************************************
      FUNCTION F_DEL_TRASPASO
       Función que sirve para borrar los datos del traspaso. Sólo se puede utilizar
       si el traspaso esta en estado Sin confirmar. Y sólo se permite a un perfil de seguridad

       1.   PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
       2.   MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.

   Retorna un valor numérico: 0 si ha borrado el traspaso y 1 si se ha producido algún error.
       *************************************************************************/
   FUNCTION f_del_traspaso(pstras IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pstras = ' || pstras;
      vobject        VARCHAR2(200) := 'PAC_IAX_traspasos.f_del_traspaso';
      v_fich         VARCHAR2(400);
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF pstras IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_result := pac_md_traspasos.f_del_traspaso(pstras, mensajes);

      IF v_result = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 109904);
      ELSE
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000455);
      END IF;

      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN v_result;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN v_result;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_result;
   END f_del_traspaso;

      /*************************************************************************
      FUNCTION F_CONFIRMAR_TRASPASO
          Función que sirve para confirmar traspaso. Sólo se puede utilizar si el traspaso está en estado Sin confirmar.

           1.  PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
           2.  MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.

   Retorna un valor numérico: 0 si ha confirmado el traspaso y 1 si se ha producido algún error.
       *************************************************************************/
   FUNCTION f_confirmar_traspaso(
      pstras IN NUMBER,
      pinout IN NUMBER,
      pextern IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pstras = ' || pstras;
      vobject        VARCHAR2(200) := 'PAC_IAX_traspasos.F_CONFIRMAR_TRASPASO';
      v_fich         VARCHAR2(400);
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF pstras IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_result := pac_md_traspasos.f_confirmar_traspaso(pstras, pinout, pextern, mensajes);

      IF v_result = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 109904);
      ELSE
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000455);
      END IF;

      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN v_result;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN v_result;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_result;
   END f_confirmar_traspaso;

   /*************************************************************************
   FUNCTION F_DESCONFIRMAR_TRASPASO
    Función que sirve para confirmar traspaso. Sólo se puede utilizar si el traspaso está en estado Confirmado.

        1.  PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
        2.  MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.

    Retorna un valor numérico: 0 si ha desconfirmado el traspaso y 1 si se ha producido algún error
    *************************************************************************/
   FUNCTION f_desconfirmar_traspaso(pstras IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pstras = ' || pstras;
      vobject        VARCHAR2(200) := 'PAC_IAX_traspasos.F_DESCONFIRMAR_TRASPASO';
      v_fich         VARCHAR2(400);
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF pstras IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_result := pac_md_traspasos.f_desconfirmar_traspaso(pstras, mensajes);

      IF v_result = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 109904);
      ELSE
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000455);
      END IF;

      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN v_result;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN v_result;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_result;
   END f_desconfirmar_traspaso;

      /*************************************************************************
      FUNCTION F_DEMORAR_TRASPASO
       Función que sirve para demorar un traspaso. Sólo se puede utilizar si el traspaso está en estado Sin confirmar.

           1.  PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
           2.  MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.

   Retorna un valor numérico: 0 si ha demorado el traspaso y 1 si se ha producido algún error.
       *************************************************************************/
   FUNCTION f_demorar_traspaso(
      pstras IN NUMBER,
      pinout IN NUMBER,
      pextern IN NUMBER,
      cmotivo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pstras = ' || pstras;
      vobject        VARCHAR2(200) := 'PAC_IAX_traspasos.F_DEMORAR_TRASPASO';
      v_fich         VARCHAR2(400);
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF pstras IS NULL
         OR cmotivo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_result := pac_md_traspasos.f_demorar_traspaso(pstras, pinout, pextern, cmotivo,
                                                      mensajes);

      IF v_result = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 109904);
      ELSE
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000455);
      END IF;

      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 9900993, vpasexec, vparam);
         RETURN v_result;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN v_result;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_result;
   END f_demorar_traspaso;

      /*************************************************************************
   FUNCTION F_ENVIAR_TRASPASO
       Función que sirve para enviar un traspaso con la norma 234.

         1. PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.

    Retorna un valor numérico: 0 si ha grabado el traspaso y un código identificativo de error si se ha producido algún problema.
    *************************************************************************/
   FUNCTION f_enviar_traspaso(pstras IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pstras = ' || pstras;
      vobject        VARCHAR2(200) := 'PAC_IAX_traspasos.F_enviar_traspaso';
      v_fich         VARCHAR2(400);
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF pstras IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_result := pac_md_traspasos.f_enviar_traspaso(pstras, mensajes);
      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN v_result;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN v_result;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_result;
   END f_enviar_traspaso;

      /*************************************************************************
      FUNCTION F_RECHAZAR_TRASPASO
       Función que sirve para rechazar un traspaso. Sólo se puede utilizar si el traspaso está en estado Sin confirmar, Confirmado o en Demora.

       1.   PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
       2.   MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.

   Retorna un valor numérico: 0 si ha rechazado el traspaso y 1 si se ha producido algún error.
       *************************************************************************/
   FUNCTION f_rechazar_traspaso(
      pstras IN NUMBER,
      pinout IN NUMBER,
      pextern IN NUMBER,
      cmotivo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pstras = ' || pstras;
      vobject        VARCHAR2(200) := 'PAC_IAX_traspasos.F_RECHAZAR_TRASPASO';
      v_fich         VARCHAR2(400);
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF pstras IS NULL
         OR cmotivo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_result := pac_md_traspasos.f_rechazar_traspaso(pstras, pinout, pextern, cmotivo,
                                                       mensajes);

      IF v_result = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 109904);
      ELSE
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000455);
      END IF;

      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 9900993, vpasexec, vparam);
         RETURN v_result;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN v_result;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_result;
   END f_rechazar_traspaso;

   /*************************************************************************
   FUNCTION F_ANULAR_TRASPASO
    Función que sirve para anular un traspaso. Sólo se puede utilizar si el traspaso está en estado Sin confirmar, Confirmado o en Demora

    1.   PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
    2.   MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.

    Retorna un valor numérico: 0 si ha borrado el traspaso y 1 si se ha producido algún error

    *************************************************************************/
   FUNCTION f_anular_traspaso(pstras IN NUMBER, cmotivo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pstras = ' || pstras;
      vobject        VARCHAR2(200) := 'PAC_IAX_traspasos.F_ANULAR_TRASPASO';
      v_fich         VARCHAR2(400);
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF pstras IS NULL
                       -- BUG 16215 - 06/10/2010 - SRA - se elimina la obligatoriedad de informar un motivo de anulación del traspaso
                        /*OR cmotivo IS NULL*/
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_result := pac_md_traspasos.f_anular_traspaso(pstras, cmotivo, mensajes);

      IF v_result = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 109904);
      ELSE
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000455);
      END IF;

      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 9900993, vpasexec, vparam);
         RETURN v_result;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN v_result;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_result;
   END f_anular_traspaso;

   /*************************************************************************
    FUNCTION F_INFORMAR_TRASPASO
       Función que sirve para informar los datos fiscales (aportaciones del año, porcentaje aportaciones 2007, fecha de antigüedad …).
       Sólo se puede utilizar si el traspaso está en estado 3-Pendientes de informar.

    Retorna un valor numérico: 0 si ha informado el traspaso y 1 si se ha producido algún error.
    *************************************************************************/
   FUNCTION f_informar_traspaso(
      pstras IN NUMBER,
      fantigi IN DATE,
      iimpanu IN NUMBER,
      nparret IN NUMBER,
      iimpret IN NUMBER,
      tmemo IN VARCHAR2,   -- BUG 15197 - PFA - Afegir camp observacions
      nparpos2006 IN NUMBER,
      porcpos2006 IN NUMBER,
      nparant2007 IN NUMBER,
      porcant2007 IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros - pstras = ' || pstras || ' fantigi = '
            || TO_CHAR(fantigi, 'dd/mm/yyyy') || ' iimpanu = ' || iimpanu;   -- solo obligatorios
      vobject        VARCHAR2(200) := 'PAC_IAX_traspasos.F_INFORMAR_TRASPASO';
      v_fich         VARCHAR2(400);
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF pstras IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_result := pac_md_traspasos.f_informar_traspaso(pstras, fantigi, iimpanu, nparret,
                                                       iimpret, tmemo, nparpos2006,
                                                       porcpos2006, nparant2007, porcant2007,
                                                       mensajes);

      IF v_result = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 109904);
      ELSE
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000455);
      END IF;

      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN v_result;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN v_result;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_result;
   END f_informar_traspaso;

/*************************************************************************
    FUNCTION F_EJECUTAR_TRASPASO
       Función que sirve para ejecutar un traspaso. Sólo se puede utilizar si el traspaso está en estado Confirmado.

    Retorna un valor numérico: 0 si ha ejecutado el traspaso y 1 si se ha producido algún error.
*************************************************************************/
   FUNCTION f_ejecutar_traspaso(
      pstras IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcagrpro IN NUMBER,
      pcinout IN NUMBER,
      pctiptras IN NUMBER,
      pcextern IN NUMBER,
      pctipder IN NUMBER,
      pctiptrassol IN NUMBER,
      piimptemp IN NUMBER,
      nporcen IN NUMBER,
      nparpla IN NUMBER,
      ccodpla IN NUMBER,
      ccompani IN NUMBER,
      ctipban IN NUMBER,
      cbancar IN VARCHAR2,
      tpolext IN VARCHAR2,
      ncertext IN NUMBER,
      pfefecto IN DATE,
      pfvalmov IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros - pstras = ' || pstras || ' psseguro = ' || psseguro || ' pnriesgo = '
            || pnriesgo || ' pcagrpro= ' || pcagrpro;   -- solo obligatorios
      vobject        VARCHAR2(200) := 'PAC_IAX_traspasos.F_EJECUTAR_TRASPASO';
      v_fich         VARCHAR2(400);
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF pstras IS NULL
         OR psseguro IS NULL
         OR pnriesgo IS NULL
         OR pcagrpro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_result := pac_md_traspasos.f_ejecutar_traspaso(pstras, psseguro, pnriesgo, pcagrpro,
                                                       pcinout, pctiptras, pcextern, pctipder,
                                                       pctiptrassol, piimptemp, nporcen,
                                                       nparpla, ccodpla, ccompani, ctipban,
                                                       cbancar, tpolext, ncertext, pfefecto,
                                                       pfvalmov, mensajes);

      IF v_result = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 109904);
      ELSE
         -- Bug 0020856 - JMF - 10/01/2012
         -- pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000455);
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_result);
      END IF;

      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN v_result;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN v_result;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_result;
   END f_ejecutar_traspaso;

   /*************************************************************************
   FUNCTION F_GET_COMPAÑIA
   Función que sirve para recuperar un nombre de compania a traves de DGS
        PCCOMPANI: Tipo numérico. Parámetro de entrada. Código de DGS compañía
        PTCOMPANI: Tipo varchar2. Parámetro de salida. Nombre de la compañía
        MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.
   Retorna un NUMBER 0 OK, 1 KO
    *************************************************************************/
   FUNCTION f_get_tcompani(
      pccompani_dgs IN VARCHAR2,
      pccompani OUT NUMBER,
      ptcompani OUT VARCHAR2,
      pctipban OUT NUMBER,
      pcbancar OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pccompani= ' || pccompani;   -- solo obligatorios
      vobject        VARCHAR2(200) := 'PAC_IAX_traspasos.f_get_tcompani';
      v_fich         VARCHAR2(400);
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF pccompani_dgs IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_result := pac_md_traspasos.f_get_tcompani(pccompani_dgs, pccompani, ptcompani,
                                                  pctipban, pcbancar, mensajes);
      RETURN v_result;
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
   END f_get_tcompani;

   /*************************************************************************
   FUNCTION f_get_ccodpla
   Función que sirve para recuperar el codigo del plan a traves del codigo DGS
        PCCODPLA_DGS: Tipo varchar2. Parámetro de salida. Código de DGS plan
        PCCODPLA: Tipo numérico. Parámetro de entrada. Código de compañía
        MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.
   Retorna un NUMBER 0 OK, 1 KO
    *************************************************************************/
   FUNCTION f_get_ccodpla(
      pccodpla_dgs IN VARCHAR2,
      pccodpla OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pccodpla_DGS= ' || pccodpla_dgs;   -- solo obligatorios
      vobject        VARCHAR2(200) := 'PAC_IAX_traspasos.f_get_ccodpla';
      v_fich         VARCHAR2(400);
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF pccodpla_dgs IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_result := pac_md_traspasos.f_get_ccodpla(pccodpla_dgs, pccodpla, mensajes);
      RETURN v_result;
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
   END f_get_ccodpla;

/* BUG 15372 - 14/07/2010 - SRA - se crea la nueva transacción f_get_traspasos_pol para que informe el bloque Traspasos en axisctr093 */
   FUNCTION f_get_traspasos_pol(
      psseguro IN seguros.sseguro%TYPE,
      pmodo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_traspasos IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
                                 := 'parámetros - psseguro:' || psseguro || ' pmodo:' || pmodo;
      vobject        VARCHAR2(200) := 'PAC_IAX_traspasos.F_GET_TRASPASOS_POL';
      v_result       t_iax_traspasos := t_iax_traspasos();
   BEGIN
      BEGIN
         v_result := pac_md_traspasos.f_get_traspasos_pol(psseguro, pmodo, mensajes);
      EXCEPTION
         WHEN OTHERS THEN
            RAISE e_object_error;
      END;

      vpasexec := 2;
      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN v_result;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN v_result;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_result;
   END f_get_traspasos_pol;
END pac_iax_traspasos;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_TRASPASOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_TRASPASOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_TRASPASOS" TO "PROGRAMADORESCSI";
