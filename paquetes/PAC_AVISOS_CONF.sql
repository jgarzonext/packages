CREATE OR REPLACE PACKAGE "PAC_AVISOS_CONF" IS
  /******************************************************************************
     NOMBRE:    pac_contragarantias
     PROPSITO: Funciones para contragarantias
  
     REVISIONES:
     Ver        Fecha        Autor             Descripcin
     ---------  ----------  ---------------  ------------------------------------
     1.0        02/03/2016  JAE              1. Creacin del objeto.
     2.0        05/03/2019  CJMR             2. Se agrega funcin para validacin de marcas
     3.0        26/09/2019  CJMR             3. IAXIS-3640. Movimientos negativos en moneda extranjera
     4.0        28/10/2019  CJMR             4. IAXIS-5422. Nota Beneficiario adicional
     5.0        01/11/2019  CJMR             5. IAXSI-5428. Validacin de la comisin para poder tener corretaje
     6.0        04/12/2019  JLTS             6. IAXIS-3264. Se crea la función f_valida_recargo para la validación de la
                                                pregunta Recargo comercial en baja de amparo debe ser igual a cero(0)
     7.0        19/02/2019   IRD             7. IAXIS - 3750 Funcion para mostrar el mensaje de plantilla USF			
	 8.0		30/03/2020	SP				 8. IAXIS-13006 CAMBIOS DE WEB COMPLIANCE     
   ******************************************************************************/
   --
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   --
   /*************************************************************************
      FUNCTION f_duplicidad_riesgo: Valida duplicidad de riesgo
      param IN psproduc   : Código del producto
      param IN psseguro   : Número identificativo interno de SEGUROS
      param IN pcidioma   : Código del Idioma
      param OUT ptmensaje : Mensajes de salida
      Devuelve            : 0 => No duplicidad  1 => Duplicidad
   *************************************************************************/
   FUNCTION f_duplicidad_riesgo(psproduc  IN NUMBER,
                                psseguro  IN NUMBER,
                                pcidioma  IN NUMBER,
                                parfix_nvalida IN NUMBER,
                                ptmensaje OUT VARCHAR2) RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_valida_plazo

      param in psseguro : Identificador seguro
      return            : NUMBER
   *************************************************************************/
   FUNCTION f_valida_plazo(psseguro  IN NUMBER,
                           ptmensaje OUT VARCHAR2) RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_valida_vig_cob

      param in psseguro : Identificador seguro
      return            : NUMBER
   *************************************************************************/
   FUNCTION f_valida_vig_cob(psseguro  IN NUMBER,
                             ptmensaje OUT VARCHAR2) RETURN NUMBER;

   FUNCTION f_valida_age_misma_sucursal(psseguro_carga IN NUMBER,
                                        pcagente_text  IN NUMBER,
                                        ptmensaje OUT VARCHAR2)
    RETURN NUMBER;

	/*************************************************************************
    Función que permite validar la existencia de codigo de barras en Carpeta y Caja
    param in pnsinies     : Número de siniestro
         return             : 0 grabación correcta
                           <> 0 grabación incorrecta
   *************************************************************************/

   FUNCTION f_finsin_val_codbarras(pnsinies      IN VARCHAR2,
   pnuevo_estado IN NUMBER ,
   pcidioma IN NUMBER,
                                   ptmensaje     OUT VARCHAR2) RETURN NUMBER;

/*************************************************************************
	FUNCTION f_mens_creaconv

	RETURN 0(ok),RETURN 1(ko)

	Bug 20880/103300 - 12/01/2012 - AMC
   *************************************************************************/
   FUNCTION f_mens_creaconv(
      pcidioma             IN       NUMBER,
      ptmensaje            OUT      VARCHAR2
   )
      RETURN NUMBER;

   --CONF-274 - 20161125 - JLTS - Ini
   FUNCTION f_aviso_suspencion_sin (
      psseguro    IN       NUMBER,
      pcidioma    IN       NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER;
   --CONF-274 - 20161125 - JLTS - Fin

	--CONF 239 JAVENDANO
    FUNCTION F_AVISO_LRE_PERSONA (
        pnnumide    IN NUMBER,
        pcidioma	IN	NUMBER,
        ptmensaje   OUT VARCHAR2
        )
    RETURN NUMBER;

    /*
   Se mostrará un aviso cuando la póliza tiene coaseguro aceptado (Aviso de póliza)
   RETURN 0(ok),1(error),2(warning)
   */
   FUNCTION f_aviso_pol_es_coasegurada(
      psseguro    IN       NUMBER,
      pcidioma    IN       NUMBER,
      parfix_nvalida IN NUMBER,
      ptmensaje   OUT      VARCHAR2
   )
      RETURN NUMBER;


  FUNCTION f_valida_tomador(
			 pcidioma	IN	NUMBER,
			 ptmensaje	OUT	VARCHAR2
	)   RETURN NUMBER;
/*************************************************************************
      FUNCTION f_valida_convenio_part

      param in psseguro : Identificador seguro
      return            : NUMBER
   *************************************************************************/
   FUNCTION f_valida_convenio_part(psseguro  IN NUMBER,
                              pcidioma    IN       NUMBER,
                              ptmensaje OUT VARCHAR2) RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_valida_convenio

      param in psseguro : Identificador seguro
      return            : NUMBER
   *************************************************************************/
   FUNCTION f_valida_convenio(psseguro  IN NUMBER,
                              pcidioma    IN       NUMBER,
                              ptmensaje OUT VARCHAR2) RETURN NUMBER;

	FUNCTION f_valida_trm(
			 pcidioma	IN	NUMBER,
			 ptmensaje	OUT	VARCHAR2
	)   RETURN NUMBER;

	/*************************************************************************
    Función que permite validar la existencia de codigo de barras en Carpeta y Caja con el ntramit
    param in pnsinies     : Número de siniestro
         return             : 0 grabación correcta
                           <> 0 grabación incorrecta
   *************************************************************************/

   FUNCTION f_finsin_tramita_val_codbarras(pnsinies      IN VARCHAR2,
                                           pntramit      IN NUMBER,
                                           pnuevo_estado IN NUMBER,
                                           pcidioma      IN NUMBER,
                                           ptmensaje     OUT VARCHAR2)
      RETURN NUMBER;

   -- INI CJMR 05/03/2019
	/*************************************************************************
    Función que permite validar la existencia de marcas para el tomador y
	asegurado al momento de crear una póliza
   *************************************************************************/
   FUNCTION f_valida_marcas(pcidioma      IN NUMBER,
                            ptmensaje     OUT VARCHAR2)
      RETURN NUMBER;
   -- FIN CJMR 05/03/2019
   
-- INICIO IAXIS-3186 03/04/2019
	/*************************************************************************
    Función que permite validar que el contratante pertenece a Convenio Grandes Beneficiarios
   *************************************************************************/
   FUNCTION f_valida_convenio_gb(psseguro  IN NUMBER,
                              pcidioma  IN NUMBER,
                              ptmensaje OUT VARCHAR2)
                              
      RETURN NUMBER;
 -- FIN IAXIS-3186 03/04/2019
   
   -- INI IAXIS-3640 CJMR 26/09/2019
   /*************************************************************************
    Función que valida la selección del certificado a afectar en un extorno
   *************************************************************************/
   FUNCTION f_valida_sel_cert_afectar (pcidioma IN NUMBER, 
                                       ptmensaje OUT VARCHAR2)
      RETURN NUMBER;
   
   /*************************************************************************
    Función que valida el valor del certificado a afectar en un extorno
   *************************************************************************/
   FUNCTION f_valida_val_cert_afectar (pcidioma IN NUMBER, 
                                       ptmensaje OUT VARCHAR2)
      RETURN NUMBER;
   -- FIN IAXIS-3640 CJMR 26/09/2019

   -- INI IAXIS-5422 CJMR 28/10/2019
   /*************************************************************************
    Función que valida cantidad de beneficiarios en una póliza, especialmente para RC
   *************************************************************************/
   FUNCTION f_valida_num_benef (psseguro  IN NUMBER,
                                pcidioma IN NUMBER, 
                                ptmensaje OUT VARCHAR2)
      RETURN NUMBER;
   -- FIN IAXIS-5422 CJMR 28/10/2019

   -- INI IAXIS-5428 CJMR 01/11/2019
   FUNCTION f_valida_comi_corretaje (pcidioma IN NUMBER, 
                                     ptmensaje OUT VARCHAR2)
   RETURN NUMBER;
   -- FIN IAXIS-5428 CJMR 01/11/2019
  -- INI IAXIS-3264 -04/12/2019
  /*************************************************************************
     FUNCTION f_valida_recargo
  
     param in psseguro : Identificador seguro
     return            : NUMBER
  *************************************************************************/
  FUNCTION f_valida_recargo(psseguro  IN NUMBER,
                            ptmensaje OUT VARCHAR2) RETURN NUMBER;
  -- FIN IAXIS-3264 -04/12/2019
  
     /*************************************************************************
     FUNCTION f_valida_formato_USF
     
     psseguro : Identificador seguro
     pcidioma          : NUMBER
     
     funcion que valida el valor asegurado, la clase de riesgo, en los productos
     de CUMPLIMIENTO para mostrar mensaje al usuario que debe llenar el formato USF. 
  *************************************************************************/
  
  --INCIO   IAXIS 3750  IRD

  FUNCTION f_valida_formato_usf (
      psseguro    IN       NUMBER,
      pcidioma    In       Number,
      ptmensaje   OUT      VARCHAR2
   )
   RETURN NUMBER;
   
  /* IAXIS-13006 : CAMBIOS DE WEB COMPLIANCE : START  */   
  FUNCTION F_VALIDA_NUM_BENEF_COMP(PSSEGURO  IN NUMBER,
                                  PCIDIOMA  IN NUMBER,
                                  PTMENSAJE OUT VARCHAR2) RETURN NUMBER;
  /* IAXIS-13006 : CAMBIOS DE WEB COMPLIANCE : END  */ 
   
END pac_avisos_conf;

