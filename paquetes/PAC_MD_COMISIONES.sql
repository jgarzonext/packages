--------------------------------------------------------
--  DDL for Package PAC_MD_COMISIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_COMISIONES" IS

   /******************************************************************************
      NOMBRE:     PAC_MD_COMISIONES
      PROPÓSITO:  Funciones de cuadros de comisiones

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        21/07/2010   AMC               1. Creación del package.
      2.0        14/09/2010   ICV               2. 0015137: MDP Desarrollo de Cuadro Comisiones
      3.0        12/09/2011   JTS               3. 19316: CRT - Adaptar pantalla de comisiones
      4.0        21/05/2015   VCG               4. 033977-204336: MSV: Creación de funciones
	  5.0        22/01/2019   ACL         		5. TCS_2 Se crean las funciones f_valida_cuadro y f_anular_cuadro.
   ******************************************************************************/
   e_object_error EXCEPTION;


   e_param_error  EXCEPTION;



   /*************************************************************************
      Recupera un cuadro de comisiones
      param in pccomisi   : codigo de comision
      param in ptcomisi   : descripcion del cuadro
      param in pctipo     : codigo de tipo
      param in pcestado   : codigo de estado
      param in pffechaini : fecha inicio
      param in pffechafin : fecha fin
      param out pcuadros  : cuadros de comision
      param out mensajes  : mensajes de error
      return              : codigo de error
   *************************************************************************/

	FUNCTION f_get_cuadroscomision(
			 pccomisi	IN	NUMBER,
			 ptcomisi	IN	VARCHAR2,
			 pctipo	IN	NUMBER,
			 pcestado	IN	NUMBER,
			 pffechaini	IN	DATE,
			 pffechafin	IN	DATE,
			 pcuadros	OUT	T_IAX_CUADROCOMISION,
			 mensajes	OUT	T_IAX_MENSAJES
	)   RETURN NUMBER;

	  /*************************************************************************
	Recupera las descripciones de las comisiones
	param in pccomisi   : codigo de comision
	param out pcuadros  : objeto con las descripciones
	param out mensajes  : mesajes de error
	return              : descripción del valor
	*************************************************************************/
	FUNCTION f_get_desccomisiones(
			 pccomisi	IN	NUMBER,
			 pcuadros	OUT	T_IAX_DESCCUADROCOMISION,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)   RETURN NUMBER;

	  /*************************************************************************
	param in pccomisi   : codigo de comision
	param in pcidioma     : codigo de idioma
	param in ptcomisi   : descripcion del cuadro
	param out mensajes  : mesajes de error
	return : codigo de error
	*************************************************************************/
	FUNCTION f_set_obj_desccuadro(
			 pcidioma	IN	NUMBER,
			 pccomisi	IN	NUMBER,
			 ptcomisi	IN	VARCHAR2,
			 pdescripciones	IN	OUT OB_IAX_DESCCUADROCOMISION,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)   RETURN NUMBER;

	  /*************************************************************************
	param in pccomisi   : codigo de comision
	param in pctipo     : codigo de tipo
	param in pcestado   : codigo de estado
	param in pfinivig   : fecha inicio vigencia
	param in pffinvig   : fecha fin vigencia
	param in pmodo      : codigo de modo
	param out mensajes  : mesajes de error
	return : codigo de error
	*************************************************************************/
	FUNCTION f_set_obj_cuadrocomision(
			 pccomisi	IN	NUMBER,
			 pctipo	IN	NUMBER,
			 pcestado	IN	NUMBER,
			 pfinivig	IN	DATE,
			 pffinvig	IN	DATE,
			 pcomision	IN	OUT OB_IAX_CUADROCOMISION,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)   RETURN NUMBER;

	  /*************************************************************************
	Devuel un cuadro de comision
	param in out pcomision   : cuadro de comision
	param out mensajes      : mesajes de error
	return : codigo de error
	*************************************************************************/
	FUNCTION f_set_traspaso_obj_bd(
			 pcomision	IN	OUT OB_IAX_CUADROCOMISION,
			 mensajes	OUT	T_IAX_MENSAJES
	)   RETURN NUMBER;

	  /*************************************************************************
	Duplica un cuadro de comisiones
	param in pccomisi_ori   : codigo de comision original
	param in pccomisi_nuevo : codigo de comision nuevo
	param in ptcomisi_nuevo : texto cuadro comision
	param out mensajes      : mesajes de error
	return : codigo de error
	*************************************************************************/
	FUNCTION f_duplicar_cuadro(
			 pccomisi_ori	IN	NUMBER,
			 pccomisi_nuevo	IN	NUMBER,
			 ptcomisi_nuevo	IN	VARCHAR2,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)   RETURN NUMBER;

	  /*************************************************************************
	Inicializa un cuadro de comisiones
	param out pcuadros  : cuadros de comision
	param out mensajes  : mensajes de error
	return              : codigo de error
	*************************************************************************/
	FUNCTION f_get_cuadrocomision(
			 pcuadros	OUT	T_IAX_CUADROCOMISION,
			 pccomisi	IN	NUMBER,
			 mensajes	OUT	T_IAX_MENSAJES
	)   RETURN NUMBER;

	FUNCTION f_get_detalle_comision(
			 pccomisi	IN	NUMBER,
			 pcagrprod	IN	NUMBER,
			 pcramo	IN	NUMBER,
			 psproduc	IN	NUMBER,
			 pcactivi	IN	NUMBER,
			 pcgarant	IN	NUMBER,
			 ptodos	IN	NUMBER,
			 pcmodcon	IN	NUMBER,
			 pfinivig	IN	DATE DEFAULT NULL,
			 pffinvig	IN	DATE DEFAULT NULL,
			 porderby	IN	NUMBER,
			 pt_comision	IN	OUT T_IAX_DETCOMISION,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)   RETURN NUMBER;

	FUNCTION f_set_detalle_comision(
			 pccomisi	IN	NUMBER,
			 psproduc	IN	NUMBER,
			 pcactivi	IN	NUMBER,
			 pcgarant	IN	NUMBER,
			 pnivel	IN	NUMBER,
			 pcmodcom	IN	NUMBER,
			 pfinivig	IN	DATE,
			 ppcomisi	IN	NUMBER,
			 pninialt	IN	NUMBER,
			 pnfinalt	IN	NUMBER,
			 pccriterio	IN	NUMBER,
			 pndesde	IN	NUMBER,
			 pnhasta	IN	NUMBER,
			 obcomision	IN	OUT OB_IAX_DETCOMISION,
			 mensajes	OUT	T_IAX_MENSAJES
	)   RETURN NUMBER;

	FUNCTION f_set_traspaso_detalle_obj_bd(
			 t_detcomision	IN	T_IAX_DETCOMISION,
			 mensajes	OUT	T_IAX_MENSAJES
	)   RETURN NUMBER;

	FUNCTION f_get_hist_cuadrocomision(
			 pccomisi	IN	NUMBER,
			 pdetcomision	OUT	T_IAX_CUADROCOMISION,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)   RETURN NUMBER;

	  /*************************************************************************
	Devuelve los cuadros de comision con su % si lo tiene asignado
	param in psproduc   : codigo de producto
	param in pcactivi   : codigo de la actividad
	param in pcgarant   : codigo de la garantia
	param in pnivel     : codigo de nivel (1-Producto,2-Actividad,3-Garantia)
	param out pt_comision   : detalle cuadros comision
	param out mensajes   : mensajes de error
	return : codigo de error
	*************************************************************************/
	FUNCTION f_get_porproducto(
			 psproduc	IN	NUMBER,
			 pcactivi	IN	NUMBER,
			 pcgarant	IN	NUMBER,
			 pcnivel	IN	NUMBER,
			 pcfinivig	IN	DATE,
			 pt_comision	OUT	T_IAX_DETCOMISION,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)   RETURN NUMBER;

	  /****************************************************************
	Duplica el detalle de comisión apartir de un ccomisi y una fecha
	param in pccomisi   : codigo de comisión
	param in pfinivi   : Fecha de inicio de vigencia
	param out mensajes   : mensajes de error
	return : codigo de error
	*************************************************************************/
	FUNCTION f_dup_det_comision(
			 pccomisi	IN	NUMBER,
			 pfinivig	IN	DATE,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)   RETURN NUMBER;

	  /*************************************************************************
	Recupera las fechas de vigencias de los cuadroas
	param in pccomisi   : codigo de comision
	param in pctipo     : codigo de tipo de consulta
	param out mensajes  : mensajes de error
	return              : codigo de error
	*************************************************************************/
	FUNCTION f_get_lsfechasvigencia(
			 psproduc	IN	NUMBER,
			 pctipo	IN	NUMBER,
			 mensajes	OUT	T_IAX_MENSAJES
	)   RETURN SYS_REFCURSOR;

	FUNCTION f_duplicar_cuadro_prod(
			 pcsproduc	IN	NUMBER,
			 pfinivig	IN	DATE,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)   RETURN NUMBER;

	FUNCTION f_get_alturas(
			 psproduc	IN	NUMBER,
			 pcactivi	IN	NUMBER,
			 pcgarant	IN	NUMBER,
			 pccomisi	IN	NUMBER,
			 pcmodcom	IN	NUMBER,
			 pfinivig	IN	DATE,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)   RETURN SYS_REFCURSOR;

	FUNCTION f_del_altura(
			 psproduc	IN	NUMBER,
			 pcactivi	IN	NUMBER,
			 pcgarant	IN	NUMBER,
			 pccomisi	IN	NUMBER,
			 pcmodcom	IN	NUMBER,
			 pfinivig	IN	DATE,
			 pninialt	IN	NUMBER,
			 pnivel	IN	NUMBER,
			 pccriterio	IN	NUMBER,
			 pnhasta	IN	NUMBER,
			 pndesde	IN	NUMBER,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)   RETURN NUMBER;

	  /*************************************************************************
	Inserta el desglose del % de comision
	param in pcactivi     Código de la actividad
	param in pcgarant     Código de la garantia
	param in pccomisi     Código comisión
	param in pcmodcom     Código de la modalidad de comisión
	param in pfinivig     Fecha inicio vigencia comisión
	param in pninialt     Inicio de la altura
	param in pcconcepto   Código concepto
	param in ppcomisi     Porcentaje de comisión
	param in psproduc     Codi producte
	param in pnfinalt     Fin de la altura
	return : codigo de error
	Bug 24905/131645 - 11/12/2012 - AMC
	*************************************************************************/
	FUNCTION f_set_comisiondesglose(
			 pcactivi	IN	NUMBER,
			 pcgarant	IN	NUMBER,
			 pccomisi	IN	NUMBER,
			 pcmodcom	IN	NUMBER,
			 pfinivig	IN	DATE,
			 pninialt	IN	NUMBER,
			 pcconcepto	IN	NUMBER,
			 ppcomisi	IN	NUMBER,
			 psproduc	IN	NUMBER,
			 pnfinalt	IN	NUMBER,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)   RETURN NUMBER;

	  /*************************************************************************
	Recupera el desglose del % de comision
	param in pcactivi     Código de la actividad
	param in pcgarant     Código de la garantia
	param in pccomisi     Código comisión
	param in pcmodcom     Código de la modalidad de comisión
	param in pfinivig     Fecha inicio vigencia comisión
	param in pninialt     Inicio de la altura
	return : desglose
	Bug 24905/131645 - 13/12/2012 - AMC
	*************************************************************************/
	FUNCTION f_get_comisiondesglose(
			 pcactivi	IN	NUMBER,
			 pcgarant	IN	NUMBER,
			 pccomisi	IN	NUMBER,
			 pcmodcom	IN	NUMBER,
			 pfinivig	IN	DATE,
			 pninialt	IN	NUMBER,
			 psproduc	IN	NUMBER,
			 pnfinalt	IN	NUMBER,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)   RETURN SYS_REFCURSOR;

	  /*************************************************************************
	Borra el desglose del % de comision
	param in pcactivi     Código de la actividad
	param in pcgarant     Código de la garantia
	param in pccomisi     Código comisión
	param in pcmodcom     Código de la modalidad de comisión
	param in pfinivig     Fecha inicio vigencia comisión
	param in pninialt     Inicio de la altura
	param in psproduc     Codi producte
	param in pnfinalt     Fin de la altura
	return : codigo de error
	Bug 24905/131645 - 14/12/2012 - AMC
	*************************************************************************/
	FUNCTION f_del_comisiondesglose(
			 pcactivi	IN	NUMBER,
			 pcgarant	IN	NUMBER,
			 pccomisi	IN	NUMBER,
			 pcmodcom	IN	NUMBER,
			 pfinivig	IN	DATE,
			 pninialt	IN	NUMBER,
			 psproduc	IN	NUMBER,
			 pnfinalt	IN	NUMBER,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)   RETURN NUMBER;

	  /*************************************************************************
	Recupera fecha vigencia
	param in pccomisi     Código comisión
	return : fecha de vigencia
	*************************************************************************/
	FUNCTION f_get_fechavigencia(
			 pccomisi	IN	NUMBER,
			 mensajes	OUT	T_IAX_MENSAJES
	)   RETURN DATE;

	  /*************************************************************************
	Inserta el parà metre per porcentaje de retrocesiòn
	param in pnempres     : Código empresa
	param in pnmesi      : Mes inicial
	param in pnmesf     : Mes final
	param in pnanulac  : Porcentaje de retrocesiòn
	return              : 0.- OK, 1.- KO
	*************************************************************************/
	FUNCTION f_ins_confclawback(
			 pnempres	IN	NUMBER,
			 pnmesi	IN	NUMBER,
			 pnmesf	IN	NUMBER,
			 pnanulac	IN	NUMBER,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)   RETURN NUMBER;

	  /*************************************************************************
	Actualitzar  el parà metre per porcentaje de retrocesiòn
	param in pnempres     : Código empresa
	param in pnmesi      : Mes inicial
	param in pnmesf     : Mes final
	param in pnanulac  : Porcentaje de retrocesiòn
	return              : 0.- OK, 1.- KO
	*************************************************************************/
	FUNCTION f_upd_confclawback(
			 pnempres	IN	NUMBER,
			 pnmesi_old	IN	NUMBER,
			 pnmesi_new	IN	NUMBER,
			 pnmesf_old	IN	NUMBER,
			 pnmesf_new	IN	NUMBER,
			 pnanulac_old	IN	NUMBER,
			 pnanulac_new	IN	NUMBER,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)   RETURN NUMBER;

	  /*************************************************************************
	Esborrar  el parà metre per porcentaje de retrocesiòn
	param in pnempres     : Código empresa
	param in pnmesi      : Mes inicial
	param in pnmesf     : Mes final
	param in pnanulac  : Porcentaje de retrocesiòn
	return              : 0.- OK, 1.- KO
	*************************************************************************/
	FUNCTION f_del_confclawback(
			 pnempres	IN	NUMBER,
			 pnmesi	IN	NUMBER,
			 pnmesf	IN	NUMBER,
			 pnanulac	IN	NUMBER,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)   RETURN NUMBER;

	  /*************************************************************************
	Consulta dades de la taula CLAWBACK_CONF
	param in pnempres     : Código empresa
	param in pnmesi      : Mes inicial
	param in pnmesf     : Mes final
	param in pnanulac  : Porcentaje de retrocesiòn
	return              : 0.- OK, 1.- KO
	*************************************************************************/
	FUNCTION f_get_confclawback(
			 pnempres	IN	NUMBER,
			 pnmesi	IN	NUMBER,
			 pnmesf	IN	NUMBER,
			 pnanulac	IN	NUMBER,
			 mensajes	OUT	T_IAX_MENSAJES
	)   RETURN SYS_REFCURSOR;
	/*************************************************************************
	 Consulta comision habitual por agente
	 param in pcagente     : Código Agente
	 param in psproduc      : Producto
	 param in pramo     : Ramo
	 param in pfefecto     : Fecha de efecto
	 return              : v_pcomisi - OK, 0.- KO
	 *************************************************************************/
     FUNCTION f_get_comsis_agente(
       pcagente IN agentes.cagente%TYPE,
       psproduc IN seguros.sproduc%TYPE,
       pramo IN NUMBER,
       pfefecto  in date,
       mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

	/*************************************************************************
	Recupera  los datos de cuadros de comisiones ya existentes
	param in ccomisi     : Código de comision
	return               : Numero de codigo de comision
	*************************************************************************/
	FUNCTION f_valida_cuadro(
			pccomisi	IN	NUMBER,
            mensajes IN OUT t_iax_mensajes)
            RETURN NUMBER;

	/*************************************************************************
	Elimina  los datos del cuadro de comision elegido
	param in ccomisi     : Código de comision
	return               : Mensaje de error
	*************************************************************************/
    FUNCTION f_anular_cuadro(
      pccomisi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_comisiones;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_COMISIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_COMISIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_COMISIONES" TO "PROGRAMADORESCSI";
