CREATE OR REPLACE PACKAGE pac_md_sin_imp_sap AS
/******************************************************************************
   NOMBRE:    pac_md_sin_imp_sap
   PROP¿SITO: Funciones para calculo de impuestos

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
    1.0       13/08/2013   NSS             Creacion
    2.0       18/01/2019   WAJ            Insertar codigo impuesto segun tipo de vinculacion
******************************************************************************/
   FUNCTION f_opencursor(squery IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Abre un cursor con la sentencia suministrada
      param in squery    : consulta a executar
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstimpuestos(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_tipos_indicador(pccodimp IN NUMBER, pcarea IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;
   --IAXIS 7655 AABC OBTIENE CONCEPTOS DE PAGO TIQUETES   
   FUNCTION f_get_concep_pago(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;   
   --IAXIS 7655 AABC OBTIENE CONCEPTOS DE PAGO TIQUETES    
   FUNCTION f_set_impuesto_prof(
      psprofes IN NUMBER,
      pccodimp IN NUMBER,
      pctipind IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_impuesto_prof(
      psprofes IN NUMBER,
      pctipind IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_indicador_prof(
      pcconpag IN NUMBER,
      psprofes IN NUMBER,
      pccodimp IN NUMBER,
      pfordpag IN DATE,
      pnsinies IN sin_tramita_localiza.nsinies%TYPE,
      pntramit IN sin_tramita_localiza.ntramit%TYPE,
      pnlocali IN sin_tramita_localiza.nlocali%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;
--INI--WAJ
   FUNCTION f_set_impuesto_per(
      pccodvin IN NUMBER,
      pccatribu IN NUMBER,
      pctipind IN NUMBER,
      psperson IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
--FIN--WAJ
END pac_md_sin_imp_sap;

/

