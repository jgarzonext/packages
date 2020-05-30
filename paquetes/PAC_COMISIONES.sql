CREATE OR REPLACE PACKAGE "PAC_COMISIONES" AUTHID CURRENT_USER IS

   /******************************************************************************
      NOMBRE:     PAC_COMISIONES
      PROPÓSITO:  Funciones de cuadros de comisiones

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        21/07/2010   AMC               1. Creación del package.
      2.0        14/09/2010   ICV               2. 0015137: MDP Desarrollo de Cuadro Comisiones
      3.0        19/10/2010   JMF               3. 0016305 CEM902 - CANVI COMISSIONS POST-ACORD MAPFRE
      4.0        12/09/2011   JTS               4. 19316: CRT - Adaptar pantalla de comisiones
      5.0        03/10/2011   DRA               5. 0019069: LCOL_C001 - Co-corretaje
      6.0        29/10/2012   DRA               6. 0022402: LCOL_C003: Adaptación del co-corretaje
      7.0        21/11/2012   DRA               7. 0024802: LCOL_C001-LCOL: Anulaci?n de p?liza con co-corretaje
      8.0        21/05/2015   VCG               8. 033977-204336: MSV: Creación de funciones
	  9.0        22/01/2019   ACL         		9. TCS_2 Se crean las funciones f_valida_cuadro y f_anular_cuadro.
      10.0       17/08/2019   JLTS              10 IAXIS-5040: Se adiciona el parametro pccompan en la funcion f_alt_comisionrec
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
      param in pidioma    : codigo del idioma
      param out pquery    : select a ejecutar
      return              : codigo de error
   *************************************************************************/

	FUNCTION f_get_cuadroscomision(
			 pccomisi	IN	NUMBER,
			 ptcomisi	IN	VARCHAR2,
			 pctipo	IN	NUMBER,
			 pcestado	IN	NUMBER,
			 pffechaini	IN	DATE,
			 pffechafin	IN	DATE,
			 pidioma	IN	NUMBER,
			 pquery	OUT	VARCHAR2
	)   RETURN NUMBER;

	FUNCTION f_set_cab_comision(
			 pccomisi	IN	NUMBER,
			 pctipo	IN	NUMBER,
			 pcestado	IN	NUMBER,
			 pfinivig	IN	DATE,
			 pffinvig	IN	DATE
	)   RETURN NUMBER;

	FUNCTION f_set_desccomision(
			 pccomisi	IN	NUMBER,
			 pcidioma	IN	NUMBER,
			 ptcomisi	IN	VARCHAR2
	)   RETURN NUMBER;

	  /*************************************************************************
	Duplica un cuadro de comisiones
	param in pccomisi_ori   : codigo de comision original
	param in pccomisi_nuevo : codigo de comision nuevo
	param in ptcomisi_nuevo : texto cuadro comision
	param in pidioma        : codigo de idioma
	return : codigo de error
	*************************************************************************/
	FUNCTION f_duplicar_cuadro(
			 pccomisi_ori	IN	NUMBER,
			 pccomisi_nuevo	IN	NUMBER,
			 ptcomisi_nuevo	IN	VARCHAR2,
			 pidioma	IN	NUMBER
	)   RETURN NUMBER;

	FUNCTION f_get_detalle_comision(
			 pccomisi	IN	NUMBER,
			 pcagrprod	IN	NUMBER,
			 pcramo	IN	NUMBER,
			 psproduc	IN	NUMBER,
			 pcactivi	IN	NUMBER,
			 pcgarant	IN	NUMBER,
			 ptodos	IN	NUMBER,
			 pfinivig	IN	DATE DEFAULT NULL,
			 pffinvig	IN	DATE DEFAULT NULL,
			 porderby	IN	NUMBER,
			 pidioma	IN	NUMBER,
			 pcmodcon	IN	NUMBER,
			 pquery	OUT	VARCHAR2
	)   RETURN NUMBER;

	FUNCTION f_set_detalle_comision(
			 psproduc	IN	NUMBER,
			 pcactivi	IN	NUMBER,
			 pcgarant	IN	NUMBER,
			 pnivel	IN	NUMBER,
			 pfinivig	IN	DATE,
			 pcmodcom	IN	NUMBER,
			 pccomisi	IN	NUMBER,
			 ppcomisi	IN	NUMBER,
			 pninialt	IN	NUMBER,
			 pnfinalt	IN	NUMBER,
			 pccriterio	IN	NUMBER,
			 pndesde	IN	NUMBER,
			 pnhasta	IN	NUMBER
	)   RETURN NUMBER;

	FUNCTION f_get_hist_cuadrocomision(
			 pccomisi	IN	NUMBER,
			 pidioma	IN	NUMBER,
			 pquery	OUT	VARCHAR2
	)   RETURN NUMBER;

	  /*************************************************************************
	Devuelve los cuadros de comision con su % si lo tiene asignado
	param in psproduc   : codigo de producto
	param in pcactivi   : codigo de la actividad
	param in pcgarant   : codigo de la garantia
	param in pnivel     : codigo de nivel (1-Producto,2-Actividad,3-Garantia)
	param in pidioma    : codigo de idioma
	param out psquery   : consulta a ejecutar
	return : codigo de error
	*************************************************************************/
	FUNCTION f_get_porproducto(
			 psproduc	IN	NUMBER,
			 pcactivi	IN	NUMBER,
			 pcgarant	IN	NUMBER,
			 pcnivel	IN	NUMBER,
			 pcfinivig	IN	DATE,
			 pcidioma	IN	NUMBER,
			 psquery	OUT	VARCHAR2
	)   RETURN NUMBER;

	  /****************************************************************
	Duplica el detalle de comisión apartir de un ccomisi y una fecha
	param in pccomisi   : codigo de comisión
	param in pfinivi   : Fecha de inicio de vigencia      return : codigo de error
	*************************************************************************/
	FUNCTION f_dup_det_comision(
			 pccomisi	IN	NUMBER,
			 pfinivig	IN	DATE
	)   RETURN NUMBER;

	  /*************************************************************************
	Anula comisión recibo.
	param in p_NRECIBO : Número recibo
	param in p_CESTREC : Estado recibo
	param in p_FMOVDIA : Fecha día que se hace el movimiento
	param in p_ICOMBRU : Comisión bruta
	param in p_ICOMRET : Retención s/Comisión
	param in p_ICOMDEV : Comisión devengada
	param in p_IRETDEV : Retención devengada
	return             : 0=OK, 1=Error
	Bug 0016305 - 19/10/2010 - JMF
	*************************************************************************/
	FUNCTION f_anu_comisionrec(
			 p_nrecibo	IN	NUMBER,
			 p_cestrec	IN	NUMBER,
			 p_fmovdia	IN	DATE,
			 p_icombru	IN	NUMBER DEFAULT NULL,
			 p_icomret	IN	NUMBER DEFAULT NULL,
			 p_icomdev	IN	NUMBER DEFAULT NULL,
			 p_iretdev	IN	NUMBER DEFAULT NULL,
			 p_cagente	IN	NUMBER DEFAULT NULL,
			 p_cgarant	IN	NUMBER DEFAULT NULL, -- BUG22402:DRA:29/10/2012
			 p_ctipcom	IN	VARCHAR2 DEFAULT 'TRASPASO'
	)
	  RETURN NUMBER;

	  /*************************************************************************
	Alta comisión recibo.
	param in p_NRECIBO : Número recibo
	param in p_CESTREC : Estado recibo
	param in p_FMOVDIA : Fecha día que se hace el movimiento
	param in p_ICOMBRU : Comisión bruta
	param in p_ICOMRET : Retención s/Comisión
	param in p_ICOMDEV : Comisión devengada
	param in p_IRETDEV : Retención devengada
	return             : 0=OK, 1=Error
	Bug 0016305 - 19/10/2010 - JMF
	*************************************************************************/
	FUNCTION f_alt_comisionrec(
			 p_nrecibo	IN	NUMBER,
			 p_cestrec	IN	NUMBER,
			 p_fmovdia	IN	DATE,
			 p_icombru	IN	NUMBER DEFAULT NULL,
			 p_icomret	IN	NUMBER DEFAULT NULL,
			 p_icomdev	IN	NUMBER DEFAULT NULL,
			 p_iretdev	IN	NUMBER DEFAULT NULL,
			 p_cagente	IN	NUMBER DEFAULT NULL,
			 p_cgarant	IN	NUMBER DEFAULT NULL, -- BUG22402:DRA:29/10/2012
			 p_icomcedida	IN	NUMBER DEFAULT NULL,
      p_ccompan IN NUMBER DEFAULT 0) -- IAXIS-5040 - JLTS - 17/08/2019

	  RETURN NUMBER;

	  /*************************************************************************
	Duplica un cuadro de comisiones de un producto
	param in pccomisi_ori   : codigo de comision original
	param in pccomisi_nuevo : codigo de comision nuevo
	param in ptcomisi_nuevo : texto cuadro comision
	param in pidioma        : codigo de idioma
	return : codigo de error
	*************************************************************************/
	FUNCTION f_duplicar_cuadro_prod(
			 pcsproduc	IN	NUMBER,
			 pcfinivig	IN	DATE
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
			 pnfinalt	IN	NUMBER
	)   RETURN NUMBER;

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
			 pnfinalt	IN	NUMBER
	)   RETURN NUMBER;

	  /*************************************************************************
	Recupera el desglose del % de comision
	param in pcactivi     Código de la actividad
	param in pcgarant     Código de la garantia
	param in pccomisi     Código comisión
	param in pcmodcom     Código de la modalidad de comisión
	param in pfinivig     Fecha inicio vigencia comisión
	param in pninialt     Inicio de la altura
	param in psproduc     Codi producte
	param in pnfinalt     Fin de la altura
	param out pdesglose   Sumatorio de los % de comision
	return : codigo de error
	Bug 24905/131645 - 17/12/2012 - AMC
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
			 pdesglose	OUT	NUMBER
	)   RETURN NUMBER;

	  /************************************************************************
	NOMBRE:     f_pcomespecial
	PROPÓSITO:  Función que encuentra el valor de la comisión
	*************************************************************************/
	FUNCTION f_pcomespecial(
			 p_sseguro NUMBER,
			 p_nriesgo NUMBER,
			 p_cgarant NUMBER,
			 p_nrecibo NUMBER,
			 p_ctipcom NUMBER,
			 p_cconcep NUMBER,
			 p_fecrec DATE,
			 p_modocal VARCHAR2,
			 p_icomisi_total	OUT	NUMBER,
			 p_icomisi_monpol_total	OUT	NUMBER,
			 p_pcomisi	OUT	NUMBER,
			 p_sproces NUMBER DEFAULT NULL,
			 p_nmovimi NUMBER DEFAULT NULL,
			 p_prorrata NUMBER DEFAULT 1 ) --, drec.nrecibo, drec.cconcep, drec.nriesgo, drec.iconcep, drec.cageven, drec.nmovima
	  RETURN NUMBER;

	FUNCTION f_grabarcomisionmovimiento(
			 --rdd quitandolo de pac_md_grabardatos
			 p_cempres	IN	NUMBER,
			 p_sseguro	IN	NUMBER,
			 p_cgarant	IN	NUMBER,
			 p_nriesgo	IN	NUMBER,
			 p_nmovimi	IN	NUMBER,
			 p_fecha	IN	DATE,
			 p_modo	IN	VARCHAR2, --, ?AR? ?P?
			 p_ipricom	IN	NUMBER,
			 p_cmodcom	IN	NUMBER,
			 p_sproces	IN	NUMBER,
			 p_mensajes	IN	OUT T_IAX_MENSAJES
	)
	  RETURN NUMBER;

	  /*************************************************************************
	Insereix el paràmetre de percentatge de retrocessió de comissions
	param in pnempres     : Código empresa
	param in pnmesi      : Mes inicial
	param in pnmesf     : Mes final
	param in pnanulac  : Porcentaje de retrocesiòn
	return              : 0.- OK, 1.- KO
	Bug 33977-204337 - 13/05/2015 - VCG
	*************************************************************************/
	FUNCTION f_ins_confclawback(
			 pnempres	IN	NUMBER,
			 pnmesi	IN	NUMBER,
			 pnmesf	IN	NUMBER,
			 pnanulac	IN	NUMBER,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)   RETURN NUMBER;

	  /*************************************************************************
	Actualitza el paràmetre de percentatge de retrocessió de comissions
	param in pnempres     : Código empresa
	param in pnmesi      : Mes inicial
	param in pnmesf     : Mes final
	param in pnanulac  : Porcentaje de retrocesiòn
	return              : 0.- OK, 1.- KO
	Bug 33977-204337 - 13/05/2015 - VCG
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
	Esborra el paràmetre de percentatge de retrocessió de comissions
	param in pnempres     : Código empresa
	param in pnmesi      : Mes inicial
	param in pnmesf     : Mes final
	param in pnanulac  : Porcentaje de retrocesiòn
	return              : 0.- OK, 1.- KO
	Bug 33977-204337 - 13/05/2015 - VCG
	*************************************************************************/
	FUNCTION f_del_confclawback(
			 pnempres	IN	NUMBER,
			 pnmesi	IN	NUMBER,
			 pnmesf	IN	NUMBER,
			 pnanulac	IN	NUMBER,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)   RETURN NUMBER;

	  /*************************************************************************
	Recupera  los datos de porcentajes de retrocesión de comisiones
	param in pnempres     : Código empresa
	param in pnmesi      : Mes inicial
	param in pnmesf     : Mes final
	param in pnanulac  : Porcentaje de retrocesiòn
	return              : codigo de error
	*************************************************************************/
	FUNCTION f_get_confclawback(
			 squery	IN	VARCHAR2,
			 mensajes	IN	OUT T_IAX_MENSAJES
	)   RETURN SYS_REFCURSOR;

	/*************************************************************************
	Recupera  los datos de cuadros de comisiones ya existentes
	param in ccomisi     : Código de comision
	return               : Numero de codigo de comision
	*************************************************************************/
	FUNCTION f_valida_cuadro(
		pccomisi	IN	NUMBER
	) RETURN NUMBER;

	/*************************************************************************
	Elimina  los datos del cuadro de comision elegido
	param in ccomisi     : Código de comision
	return               : Mensaje de error
	*************************************************************************/
    FUNCTION f_anular_cuadro(
      pccomisi IN NUMBER)
      RETURN NUMBER;

END pac_comisiones;

/

  GRANT EXECUTE ON "AXIS"."PAC_COMISIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_COMISIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_COMISIONES" TO "PROGRAMADORESCSI";
