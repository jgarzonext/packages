--------------------------------------------------------
--  DDL for Package PAC_MD_PROVISIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_PROVISIONES" AS
/******************************************************************************
   NOMBRE:       PAC_MD_PROVISIONES
   PROP¿SITO:  Funciones para gestionar las provisiones

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        18/09/2008   APD                1. Creaci¿n del package.

******************************************************************************/

   /*************************************************************************
      Recupera el par¿metro de proceso
      param in pempresa  : c¿digo de empresa
      param in pprevio   : radio button previo/real
      param in pprovis   : c¿digo de la provisi¿n
      param in ptcprovis : descripci¿n corta de la provisi¿n
      param in pfecha    : ¿ltimo d¿a del mes y a¿o informados
      param out psproces : c¿digo del proceso
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_sproces(
      pempresa IN NUMBER,
      pprevio IN NUMBER,
      pprovis IN NUMBER,
      ptprovis IN VARCHAR2,
      pfecha IN DATE,
      mensajes IN OUT t_iax_mensajes,
      psproces OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      Recupera todas las provisiones existentes seg¿n la empresa seleccionada
      param in pempresa  : c¿digo de empresa
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_provisiones_emp(pempresa IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /*************************************************************************
      Recupera todas las provisiones existentes
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_provisiones(mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /*************************************************************************
      Recupera todas las provisiones existentes y muestra el c¿digo de la nueva provisi¿n
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_provisiones_nueva(mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /*************************************************************************
      Recupera todas las descripciones de una provisi¿n en los diferentes idiomas que exista
      param in pprovis   : c¿digo de la provision
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_desprovisiones(pprovis IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /*************************************************************************
      Actualiza o inserta una provisi¿n
      param in pempresa  : c¿digo de empresa
      param in pprovis   : c¿digo de la provision
      param in pfbaja    : fecha de baja de la provisi¿n
      param in ptipoprov : c¿digo del tipo de provisi¿n
      param in pcreport  : Nombre del listado de la provisi¿n
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_grabar_provisiones(
      pempresa IN NUMBER,
      pprovis IN NUMBER,
      pfbaja IN DATE,
      ptipoprov IN NUMBER,
      pcreport IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Actualiza o inserta una descripci¿n de provisi¿n
      param in pprovis   : c¿digo de la provision
      param in pcidioma  : idioma de la descripci¿n de la provisi¿n
      param in ptcprovis : descripci¿n corta de la provisi¿n
      param in ptlprovis : descripci¿n larga de la provisi¿n
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_grabar_desprovisiones(
      pprovis IN NUMBER,
      pcidioma IN NUMBER,
      ptcprovis IN VARCHAR2,
      ptlprovis IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Valida si una provisi¿n ya existe
      param in pprovis   : c¿digo de la provision
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_validar_provision(pprovis IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Recupera la cadena para poder ejecutar el report con los par¿metros correspondientes
      param in pempresa  : c¿digo de la empresa
      param in pprevio   : radio button previo/real
      param in pprovis   : c¿digo de la provisi¿n
      param in pfecha    : ¿ltimo d¿a del mes y a¿o informados
      param in pcagente  : c¿digo de agente si est¿ informado
      param in psubagente : check de incluir subagentes en el report
      param out mensajes : mensajes de error
      return             : cadena para poder ejecutar el report
   *************************************************************************/
   FUNCTION f_get_report_provision(
      pempresa IN NUMBER,
      pprevio IN NUMBER,
      pprovis IN NUMBER,
      pmes IN NUMBER,
      panyo IN NUMBER,
      pcagente IN NUMBER,
      psubagente IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /*************************************************************************
      Llama al PAC_MAP para ejecutar N maps que pasasmos en pprovis separados por @
        param in cmaps: Tipo car¿cter. Ids. de los maps. separados por '@'
        param in Pfecha: Tipo car¿cter. fecha de calculo en formato ddmmyyyy
        param in Pcempres: Tipo car¿cter. CEMPRESA
        param out MENSAJES: Tipo t_iax_mensajes. Par¿metro de Salida. Mensaje de error
        return             : Retorna un NUMERICO 0 ok / 1 KO
   *************************************************************************/
   FUNCTION f_llama_multimap_provis(
      cmaps IN VARCHAR2,
      pfecha IN VARCHAR2,
      pcempres IN NUMBER,
      fichero IN OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
      Recupera los datos para una una provision por garantia
      param in sseguro   : c¿digo de seguro
      param in nriesgo   : c¿digo del riesgo
      param in cgarant   : c¿digo de garantia
      param in nmovimi   : c¿digo de movimiento
      param in fecha     : fecha de provision
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_detalle_pu(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pnmovimi IN NUMBER,
      pfecha IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /*************************************************************************
       Llama al PAC_MAP para ejecutar N maps que pasasmos en pprovis separados por @
       mediante un JOB en batch
         param in cmaps: Tipo car¿cter. Ids. de los maps. separados por '@'
         param in Pfecha: Tipo car¿cter. fecha de calculo en formato ddmmyyyy
         param in Pcempres: Tipo car¿cter. CEMPRESA
         param out MENSAJES: Tipo t_iax_mensajes. Par¿metro de Salida. Mensaje de error
         return             : Retorna un NUMERICO 0 ok / 1 KO
    *************************************************************************/
   FUNCTION f_llama_multimap_provis_batch(
      cmaps IN VARCHAR2,
      pfecha IN VARCHAR2,
      pcempres IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Llama al PAC_MAP para ejecutar N maps que pasasmos en pprovis separados por @
      y enviar por correo el resultado
        param in pcmaps: Tipo car¿cter. Ids. de los maps. separados por '@'
        param in pparam_map: Tipo car¿cter. Parametros a usar para generar los maps
        param in Pcempres: Tipo car¿cter. CEMPRESA
        param in psproces: Codigo de proceso interno
   *************************************************************************/
   PROCEDURE p_listar_provisiones(
      pcmaps IN VARCHAR2,
      pparam_map IN VARCHAR2,
      pcempres IN VARCHAR2,
      psproces IN NUMBER);

	/**********************************************************************
      FUNCTION F_GRABAR_EXCLUSIONES
      Funci¿n que almacena los datos de la exclusion.
      Firma (Specification)
      Param IN pnpoliza    : npoliza
      Param IN pnrecibo    : nrecibo
	    Param IN pcobservexc : cobservexc
	    Param IN pcprovisi   : cprovisi
	    Param IN pcobservp   : pcobservp
	    Param IN pcnprovisi  : pcnprovisi
	    Param IN pcobservnp  : pcobservnp
	    Param IN pfalta      : pfalta
	    Param IN pfbaja      : pfbaja
      Param OUT mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
    **********************************************************************/
    FUNCTION f_grabar_exclusiones(
         pnpoliza IN NUMBER,
         pnrecibo IN NUMBER,
	    pcobservexc IN VARCHAR2,
	      pcprovisi IN NUMBER,
	      pcobservp IN VARCHAR2,
	     pcnprovisi IN NUMBER,
	     pcobservnp IN VARCHAR2,
	         pfalta IN DATE,
	         pfbaja IN DATE,
         mensajes IN OUT T_IAX_MENSAJES )
      RETURN NUMBER;


   /**********************************************************************
      FUNCTION F_DEL_EXCLUSIONES
      Funci¿n que elimina de la exclusion por numero de poliza
      Param IN pnpoliza: npoliza
      Param IN pnrecibo : nrecibo
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_del_exclusiones(
        pnpoliza IN exclus_provisiones.npoliza%TYPE,
        pnrecibo IN exclus_provisiones.nrecibo%TYPE,
        mensajes IN OUT T_IAX_MENSAJES)
       RETURN NUMBER;


   /**********************************************************************
      FUNCTION F_GET_EXCLUSIONES
      Funci¿n que retorna todas las exclusiones existentes de acuerdo a la
      consulta.
      Param IN  pcsucursal  : csucursal
      Param IN  pfdesde     : fdesde
      Param IN  pfhasta     : fhasta
      Param IN  pnpoliza    : npoliza
      Param IN  pnrecibo    : nrecibo
      Param IN  pnit        : nit
      Param IN  pnnumide    : nnumide
      Param IN  pcagente    : cagente
      Param OUT PRETCURSOR  : SYS_REF_CURSOR
    **********************************************************************/
     FUNCTION f_get_exclusiones(
        pcsucursal IN NUMBER,
           pfdesde IN DATE,
           pfhasta IN DATE,
          pnpoliza IN NUMBER,
          pnrecibo IN NUMBER,
              pnit IN NUMBER,
          pnnumide IN VARCHAR2,
          pcagente IN NUMBER,
          mensajes IN OUT T_IAX_MENSAJES)
      RETURN VARCHAR2;

   /**********************************************************************
      FUNCTION F_GET_EXCLUSIONESBYPK
      Funci¿n que retorna todas las exclusiones existentes de acuerdo a la
      consulta.
      Param IN  pnpoliza    : npoliza
      Param IN  pnrecibo    : nrecibo
      Param OUT PRETCURSOR  : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_exclusionesbypk(
          pnpoliza IN NUMBER,
          pnrecibo IN NUMBER,
          mensajes IN OUT T_IAX_MENSAJES)
      RETURN VARCHAR2;

    /**********************************************************************
      FUNCTION F_GET_EXISTEPOLIZARECIBO
      Funci¿n que retorna si existe o no poliza y recibo
      Param IN  pnpoliza    : npoliza
      Param IN  pnrecibo    : nrecibo
      Param OUT PRETCURSOR  : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_existepolizarecibo(
          pnpoliza IN NUMBER,
          pnrecibo IN NUMBER,
          mensajes IN OUT T_IAX_MENSAJES)
      RETURN VARCHAR2;
END pac_md_provisiones;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_PROVISIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PROVISIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PROVISIONES" TO "PROGRAMADORESCSI";
