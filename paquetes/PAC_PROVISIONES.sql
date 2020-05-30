--------------------------------------------------------
--  DDL for Package PAC_PROVISIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PROVISIONES" IS
   PROCEDURE proceso_batch_cierre(
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE);

   FUNCTION f_sproces(
      pempresa IN NUMBER,
      pprevio IN NUMBER,
      pprovis IN NUMBER,
      ptprovis IN VARCHAR2,
      pfecha IN DATE,
      pcidioma IN NUMBER,
      psproces OUT NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      Recupera todas las provisiones existentes seg¿n la empresa seleccionada
      param in pempresa  : c¿digo de empresa
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_provisiones_emp(pempresa IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      Recupera todas las provisiones existentes
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_provisiones(pcidioma IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      Recupera todas las provisiones existentes y muestra el c¿digo de la nueva provisi¿n
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_provisiones_nueva(pcidioma IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      Recupera todas las descripciones de una provisi¿n en los diferentes idiomas que exista
      param in pprovis   : c¿digo de la provision
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_desprovisiones(pprovis IN NUMBER)
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
      pcreport IN VARCHAR2)
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
      ptlprovis IN VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
      Valida si una provisi¿n ya existe
      param in pprovis   : c¿digo de la provision
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_validar_provision(pprovis IN NUMBER)
      RETURN NUMBER;


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
      Param IN pnpoliza : npoliza
      Param IN pnrecibo : nrecibo
     **********************************************************************/
      FUNCTION f_del_exclusiones(
        pnpoliza IN exclus_provisiones.npoliza%TYPE,
        pnrecibo IN exclus_provisiones.nrecibo%TYPE)
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
          pcagente IN NUMBER)
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
          pnrecibo IN NUMBER)
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
          pnrecibo IN NUMBER)
      RETURN VARCHAR2;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_PROVISIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROVISIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROVISIONES" TO "PROGRAMADORESCSI";
