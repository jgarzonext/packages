CREATE OR REPLACE PACKAGE pac_iax_sin_imp_sap AS
/******************************************************************************
   NOMBRE:    PAC_IAX_PROF
   PROPÓSITO: Funciones para calculo de impuestos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
    1.0       13/08/2013   NSS             Creacion
	2.0       17/01/2019   WAJ             Insert a la tabla per_indicadores para guardar los indicadores por personas
******************************************************************************/
   FUNCTION f_get_lstimpuestos(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_tipos_indicador(pccodimp IN NUMBER, pcarea IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;
   --IAXIS 7655 AABC Conceptos de pago tiquetes aereos 
   FUNCTION f_get_concep_pago(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;
   --IAXIS 7655 AABC Conceptos de pago tiquetes aereos
   FUNCTION f_set_impuesto_prof(
      psprofes IN NUMBER,
      pccodimp IN NUMBER,
      pctipind IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_impuesto_prof(
      psprofes IN NUMBER,
      pctipind IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_indicador_prof(
      pcconpag IN NUMBER,
      psprofes IN NUMBER,
      pccodimp IN NUMBER,
      pfordpag IN DATE,
      pnsinies IN sin_tramita_localiza.nsinies%TYPE,
      pntramit IN sin_tramita_localiza.ntramit%TYPE,
      pnlocali IN sin_tramita_localiza.nlocali%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;
 --INI--WAJ
         FUNCTION f_set_impuesto_per(
      pccodvin IN NUMBER,
      pccatribu IN NUMBER,
      pctipind IN NUMBER,
      psperson IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
 --FIN--WAJ
END pac_iax_sin_imp_sap;

/