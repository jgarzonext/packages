--------------------------------------------------------
--  DDL for Package Body PAC_IAX_DOCREQUERIDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_DOCREQUERIDA" AS
   /******************************************************************************
      NOMBRE:       PAC_IAX_DOCREQUERIDA
      PROPÓSITO: Funciones relacionadas con la documentación requerida

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  --------  ------------------------------------
      1.0        10/05/2011   JMP      1. Creación del package.
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
         F_GET_DIRECTORIO
      Obtiene el directorio donde se subirán los ficheros.
      param out ppath                : directorio
      param out t_iax_mensajes       : mensajes de error
      return                         : 0 todo correcto
                                       1 ha habido un error
   *************************************************************************/
   FUNCTION f_get_directorio(ppath OUT VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_error        axis_literales.slitera%TYPE := 0;
      v_pasexec      NUMBER(3) := 1;
      v_param        VARCHAR2(500);
      v_object       VARCHAR2(200) := 'PAC_IAX_DOCREQUERIDA.f_get_directorio';
   BEGIN
      v_error := pac_md_docrequerida.f_get_directorio('INFORMES_SERV', ppath, mensajes);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

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
   END f_get_directorio;

   --INI 18351: LCOL003 - Documentación requerida en contratación y suplementos
   /*************************************************************************
    F_AVISO_DOCREQ_PENDIENTE
      Para las empreses que deben retener la emisión porque hay documentación requerida
      obligatoaria, devuelve un mensaje de confirmación
      param in  psseguro                : sseguro
      param in  pnmovimi                : Numero de movimiento de la poliza
      param out t_iax_mensajes       : mensajes de error
      return                         : 0 todo correcto
                                       1 aviso
                                       2 error
   ****************************************************************************/
   FUNCTION f_aviso_docreq_pendiente(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_error        axis_literales.slitera%TYPE := 0;
      v_pasexec      NUMBER(3) := 1;
      v_param        VARCHAR2(500);
      v_object       VARCHAR2(200) := 'PAC_IAX_DOCREQUERIDA.f_aviso_docreq_pendiente';
      v_produce_req  NUMBER := 0;
      v_haypendiente NUMBER := 0;
   BEGIN
      v_haypendiente :=
         pac_md_docrequerida.f_aviso_docreq_pendiente(psseguro,
                                                      NVL(pnmovimi,
                                                          pac_iax_produccion.vnmovimi),
                                                      psproduc, pcactivi, mensajes);
      v_produce_req := NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                         'PRODUCE_REQUERIDA'),
                           0);

      IF v_produce_req = 1
         AND v_haypendiente = 1 THEN
         --Crear nuevo mensaje de tipo ERROR.
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9902065);
      ELSIF v_produce_req = 2
            AND v_haypendiente = 1 THEN
         --Crear nuevo mensaje de tipo aviso. No error.
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9902064);
      END IF;

      RETURN v_error;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 2;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 2;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 2;
   END f_aviso_docreq_pendiente;

--FIN 18351: LCOL003 - Documentación requerida en contratación y suplementos

   /*************************************************************************
         f_tienerequerida
      Obtiene 1 si el producto tiene documentació requerida
      return                         : 0 no
                                       1 si
   *************************************************************************/
   FUNCTION f_tienerequerida(psproduc IN NUMBER)
      RETURN NUMBER IS
      v_error        axis_literales.slitera%TYPE := 0;
      v_pasexec      NUMBER(3) := 1;
      v_param        VARCHAR2(500);
      v_object       VARCHAR2(200) := 'PAC_IAX_DOCREQUERIDA.f_tienerequerida';
      v_produce_req  NUMBER := 0;
      v_return       NUMBER := 0;
   BEGIN
      v_produce_req := NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                         'PRODUCE_REQUERIDA'),
                           0);

      IF v_produce_req <> 0 THEN
         SELECT COUNT(1)
           INTO v_return
           FROM doc_docurequerida
          WHERE sproduc = psproduc;

         IF v_return > 0 THEN
            v_return := 1;
         END IF;
      END IF;

      RETURN v_return;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 0;
   END f_tienerequerida;

   FUNCTION f_docreq_pendiente(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_error        axis_literales.slitera%TYPE := 0;
      v_pasexec      NUMBER(3) := 1;
      v_param        VARCHAR2(500);
      v_object       VARCHAR2(200) := 'PAC_IAX_DOCREQUERIDA.f_docreq_pendiente';
      v_produce_req  NUMBER := 0;
      v_haypendiente NUMBER := 0;
   BEGIN
      v_haypendiente := 0;
      v_produce_req := NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                         'PRODUCE_REQUERIDA'),
                           0);

      IF v_produce_req <> 0 THEN
         v_haypendiente :=
            pac_md_docrequerida.f_docreq_pendiente(psseguro,
                                                   NVL(pnmovimi, pac_iax_produccion.vnmovimi),
                                                   psproduc, pcactivi, mensajes);
      END IF;

      RETURN v_haypendiente;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 2;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 2;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 2;
   END f_docreq_pendiente;

   FUNCTION f_get_docurequerida(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN T_IAX_DOCREQUERIDA IS
      v_pasexec NUMBER := 1;
      v_param   VARCHAR2(2000) := 'psseguro= ' || psseguro;
      v_object  VARCHAR2(2000) := 'PAC_IAX_DOCREQUERIDA.f_get_docurequerida';
      vt_docreq T_IAX_DOCREQUERIDA:=t_iax_docrequerida ();
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;
      --
      vt_docreq := pac_md_docrequerida.f_get_docurequerida(psseguro, pnmovimi, mensajes);
      --
      RETURN vt_docreq;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN vt_docreq;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN vt_docreq;
      WHEN OTHERS THEN
         RETURN vt_docreq;
   END f_get_docurequerida;

   FUNCTION f_grabardocrequeridapol(
      pseqdocu IN NUMBER,
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pcactivi IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pninqaval IN NUMBER,
      pcdocume IN NUMBER,
      pctipdoc IN NUMBER,
      pcclase IN NUMBER,
      pnorden IN NUMBER,
      ptdescrip IN VARCHAR2,
      ptfilename IN VARCHAR2,
      padjuntado IN NUMBER,
      pcrecibido IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_error   NUMBER := 0;
	    v_pasexec NUMBER (3) := 1;
	    v_object  VARCHAR2 (200):='PAC_IAX_DOCREQUERIDA.f_grabardocrequeridapol';
	    v_param   VARCHAR2 (500):='pseqdocu: '
	                          || pseqdocu
	                          || ' - psproduc: '
	                          || psproduc
	                          || ' - psseguro: '
	                          || psseguro
	                          || ' - pcactivi: '
	                          || pcactivi
	                          || ' - pnmovimi: '
	                          || pnmovimi
	                          || '- pnriesgo: '
	                          || pnriesgo
	                          || ' - pninqaval: '
	                          || pninqaval
	                          || ' - pcdocume: '
	                          || pcdocume
	                          || ' - pctipdoc: '
	                          || pctipdoc
	                          || ' - pcclase: '
	                          || pcclase
	                          || ' - pnorden: '
	                          || pnorden
	                          || ' - ptdescrip: '
	                          || ptdescrip
	                          || ' - ptfilename: '
	                          || ptfilename
	                          || ' - padjuntado: '
	                          || padjuntado
                            || ' - pcrecibido: '
	                          || pcrecibido;
   BEGIN
      --
      v_error := pac_md_docrequerida.f_grabardocrequeridapol(pseqdocu, psproduc, psseguro, pcactivi, pnmovimi, pnriesgo, pninqaval, pcdocume, pctipdoc, pcclase, pnorden, ptdescrip, ptfilename, padjuntado, pcrecibido, mensajes);
      --
	    IF v_error <> 0 THEN
	      RAISE e_object_error;
	    END IF;
      --
	    COMMIT;
      --
	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
       pac_iobj_mensajes.p_tratarmensaje (mensajes, v_object, 1000005, v_pasexec, v_param);
       ROLLBACK;
       RETURN 1;
    WHEN e_object_error THEN
       pac_iobj_mensajes.p_tratarmensaje (mensajes, v_object, 1000006, v_pasexec, v_param);
       ROLLBACK;
       RETURN 1;
    WHEN OTHERS THEN
       pac_iobj_mensajes.p_tratarmensaje (mensajes, v_object, 1000001, v_pasexec, v_param, psqcode=>SQLCODE, psqerrm=>SQLERRM);
       ROLLBACK;
       RETURN 1;
   END f_grabardocrequeridapol;

END pac_iax_docrequerida;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_DOCREQUERIDA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_DOCREQUERIDA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_DOCREQUERIDA" TO "PROGRAMADORESCSI";
