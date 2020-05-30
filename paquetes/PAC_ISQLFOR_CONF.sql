create or replace PACKAGE "PAC_ISQLFOR_CONF" AS


/******************************************************************************
   NOMBRE:      pac_impresion_CONF
   PROPÓSITO: Nuevo package con las funciones que se utilizan en las impresiones.
   En este package principalmente se utilizarÃ¿Â¡ para funciones de validación de si un documento se imprime o no.

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
    1.0        18/03/2015   FFO              1. CREACION
    2.0        12/02/2019   AABC             2.TC464 SPERSON_DEUD, SPERSON_ACRE  
    3.0        14/03/2019   ACL              3. TCS_309: Se agrega funciones
    4.0        18/03/2019   ACL              4. TCS_309: Se agrega funcion f_letras_plazo
    5.0        20/03/2019   ACL              5. TCS_19: Se crea la funciÃ³n f_intermediario
    6.0        21/03/2019   ACL              6. TCS_19: Se crea funciones para codeudor
    7.0        22/03/2019   Swapnil          7. Cambios de IAXIS-3286
    8.0        28/03/2019   ACL              8. IAXIS-2136 Se crean funciones para la caratula de poliza
    9.0        03/04/2019   ACL              9. IAXIS-2136 Se crean funciones para traer los datos del beneficiario
    10.0       05/04/2019   ACL              10. IAXIS-2136 Se crean funciones para producto caucion judicial  
  	11.0       06/05/2019   ACL              11. IAXIS-2136 Se crean las funciones f_tex_clausulado y f_texto_exclusion
  	12.0       09/05/2019   ACL              12. IAXIS-2136 Se agrega la función f_valor_iva_pesos
  	13.0       10/05/2019   ACL              13. IAXIS-3656 Se crean las funciones f_tip_movim y f_delega
    14.0       14/05/2019   RABQ             14. IAXIS-3750 Creación función indicadores para reporte USF
    15.0       14/05/2019   ACL              15. IAXIS-2136 Se crea la funcion f_agente_new.
    16.0       11/02/2020   JLTS             16. IAXIS-2122 Se ajusta la función f_get_porcenfinanci para que tome los datos correctamente
******************************************************************************/
   e_object_error EXCEPTION;


   e_param_error  EXCEPTION;




  FUNCTION f_factu_intermedi (
       pcagente IN  NUMBER,
       pcempres IN  NUMBER,
       pffecmov IN  DATE,
       ptipo  IN  NUMBER
  )   RETURN VARCHAR2;

/******************************************************************************
   NOMBRE:      f_per_relacionadas
   PROPÃ“SITO:odtener datos de personas relacionadas

   ptipo: tipo de perona relacionada,
        1 Representante legal
        2 Sede
        3 Miembro consorcio

   pdato: dato a odtener
        1 nombre
        2 nit
        3 direccion

   REVISIONES:
   Ver        Fecha        Autor             DescripciÃ³n
   ---------  ----------  ---------------  ------------------------------------
    1.0        06/07/2016   FFO                1. CREACION
******************************************************************************/
  FUNCTION f_per_relacionadas (
    ptipo     IN      NUMBER,
    pdato     IN      NUMBER,
    pagente   IN      NUMBER
  )  RETURN VARCHAR2;

/******************************************************************************
   NOMBRE:      f_per_socios
   PROPÃ“SITO:odtener datos de personas relacionadas que sean socios


   pdato: dato a odtener
        1 nombre
        2 nit
        3 direccion

   REVISIONES:
   Ver        Fecha        Autor             DescripciÃ³n
   ---------  ----------  ---------------  ------------------------------------
    1.0        06/07/2016   FFO                1. CREACION
******************************************************************************/
  FUNCTION f_per_socios (
    pdato     IN      NUMBER,
    pagente   IN      NUMBER
  )  RETURN VARCHAR2;

/******************************************************************************
   NOMBRE:      f_get_sucursal
   PROPÃ“SITO:octener el cosigo o nombre de la sucursar de un agente


   pdato: dato a odtener
        1 ptipo
        2 pcagente


   REVISIONES:
   Ver        Fecha        Autor             DescripciÃ³n
   ---------  ----------  ---------------  ------------------------------------
    1.0        10/25/2016   FFO                1. CREACION
******************************************************************************/
  FUNCTION f_get_sucursal (
    ptipo     IN      NUMBER,
    pcagente    IN      NUMBER
  )  RETURN VARCHAR2;

  /******************************************************************************
   NOMBRE:      f_per_socios_cons
   PROPÃ“SITO:odtener datos de personas relacionadas que sean socios consorcio


   pdato: dato a odtener
        1 nombre
        2 nit
        3 direccion
        4 %part
        5 mail
        6 tel
        7 ciudad

   REVISIONES:
   Ver        Fecha        Autor             DescripciÃ³n
   ---------  ----------  ---------------  ------------------------------------
    1.0        06/07/2016   FFO                1. CREACION
******************************************************************************/
  FUNCTION f_per_socios_cons (
    pdato     IN    NUMBER,
    vseguro  IN    NUMBER,
    vcdomici  IN    NUMBER DEFAULT 1
  )  RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION f_garantias_contratadas
      FunciÃ³n que se utilizarÃ¡ para obtener los datos de las garantÃ­as contratadas en un convenio,su capital asegurado, carencia, franquicia, limite prestaciÃ³n y RevalorizaciÃ³n.
      param in P_SSEGURO    : NÃºmero de seguro
      param in CIDIOMA     : Identificador de idioma.
      param in P_TIPO    : 1 â€“ 1er Columna desc. de garantÃ­as,  textos 2- 2Âº columna,Capitales asegurados, primas,etc
      return                : Tablas de donde se obtienen los datos, por defecto POL.
   *************************************************************************/
   FUNCTION f_garantias_contratadas(
      p_sseguro IN NUMBER,
      p_cidioma IN NUMBER,
      p_tipo IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION f_get_cx|
      param in P_SSEGURO    : NÃºmero de seguro
      param in CIDIOMA     : Identificador de idioma.
      param in P_TIPO    : 1 â€“ 1er Columna desc. de garantÃ­as,  textos 2- 2Âº columna,Capitales asegurados, primas,etc
      return                : Tablas de donde se obtienen los datos, por defecto POL.
   *************************************************************************/
   FUNCTION f_get_contratragarantias(
      p_sseguro IN NUMBER,
      p_cidioma IN NUMBER,
      p_tipo IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION f_get_coaseguro
      param in P_SSEGURO    : NÃºmero de seguro
      param in CIDIOMA     : Identificador de idioma.
      param in P_TIPO    : 1 â€“ 1er Columna desc. de garantÃ­as,  textos 2- 2Âº columna,Capitales asegurados, primas,etc
      return                : Tablas de donde se obtienen los datos, por defecto POL.
   *************************************************************************/
   FUNCTION f_get_coaseguro(
      p_sseguro IN NUMBER,
      p_cidioma IN NUMBER,
      p_tipo IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION f_get_tramitejudicial
      param in P_SSEGURO    : NÃºmero de seguro
      param in CIDIOMA     : Identificador de idioma.
      param in P_TIPO    : 1 â€“ 1er Columna desc. de garantÃ­as,  textos 2- 2Âº columna,Capitales asegurados, primas,etc
      return                : Tablas de donde se obtienen los datos, por defecto POL.
   *************************************************************************/
   FUNCTION f_get_tramitejudicial(
      p_sseguro IN NUMBER,
      p_cidioma IN NUMBER,
      p_tipo IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION f_get_tramitejudicial
      param in p_nsinies    : NÃºmero de siniestro
      param in CIDIOMA     : Identificador de idioma.
      param in P_TIPO    : 1 â€“ 1er Columna desc. de garantÃ­as,  textos 2- 2Âº columna,Capitales asegurados, primas,etc
      return                : Tablas de donde se obtienen los datos, por defecto POL.
   *************************************************************************/
   FUNCTION f_get_tramitecnico(
      p_nsinies IN NUMBER,
      p_cidioma IN NUMBER,
      p_tipo IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION f_get_reaseguro
      param in p_sseguro    : NÃºmero de seguro
      param in CIDIOMA     : Identificador de idioma.
      param in P_TIPO    : 1 â€“ aÃ±o, 2 RETENCIÃ“N,  3 %RET,
                              4 PARTE 1,  5 %C1,
                              6 PARTE 2,  7 %C2,
                              8 PARTE 3,  9 %C3
                              10 FACULTATIVO,   11 %FA.

      return                : Tablas de donde se obtienen los datos, por defecto POL.
   *************************************************************************/
   FUNCTION f_get_reaseguro(
      p_sseguro IN NUMBER,
      p_cidioma IN NUMBER,
      p_tipo IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION f_get_conpagopersona
      param in p_sperson    : codigo persoa
      param in CIDIOMA     : Identificador de idioma.
      param in P_TIPO    :
      return                : Tablas de donde se obtienen los datos, por defecto POL.
   *************************************************************************/
   FUNCTION f_get_conpagopersona(
      p_sperson IN NUMBER,
      p_cidioma IN NUMBER,
      p_tipo IN NUMBER,
      p_fdesde IN   DATE,
      p_fhasta IN   DATE)
      RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION f_get_conpagopersona
      param in p_sperson    : codigo persoa
      p_parametro IN VARCHAR2 :nombre parametro
      param in CIDIOMA     : Identificador de idioma.
      param in p_sfinanci    : sfinanci
      return                : Tablas de donde se obtienen los datos, por defecto POL.
   *************************************************************************/
   FUNCTION f_get_ficha(
      p_parametro IN VARCHAR2,
      p_cidioma IN NUMBER,
      p_sfinanci IN NUMBER,
      p_nmovimi  IN NUMBER,
      p_tipo   IN NUMBER)
      RETURN VARCHAR2;
      
   /*************************************************************************
      FUNCTION f_get_conpagopersona
      param in p_sperson    : codigo persoa
      p_parametro IN VARCHAR2 :nombre parametro
      param in CIDIOMA     : Identificador de idioma.
      param in p_sfinanci    : sfinanci
      return                : Tablas de donde se obtienen los datos, por defecto POL.
   *************************************************************************/
   FUNCTION f_get_ficha(
      p_parametro IN VARCHAR2,
      p_cidioma IN NUMBER,
      p_sfinanci IN NUMBER,
      p_tipo   IN NUMBER)
      RETURN VARCHAR2;

    /*************************************************************************
      FUNCTION f_get_sfinanci
      param in p_sperson    : codigo persoa

   *************************************************************************/
   FUNCTION f_get_sfinanci(
      p_sperson IN NUMBER,
      p_tipo   IN NUMBER)
      RETURN VARCHAR2;

    /*************************************************************************
      FUNCTION f_get_porcenfinanci
      p_parametro1 IN VARCHAR2,
      p_sfinanci1   IN NUMBER,
      p_parametro1 IN VARCHAR2,
      p_sfinanci1   IN NUMBER,

   *************************************************************************/
   FUNCTION f_get_porcenfinanci(
      p_tipo   IN NUMBER,
      p_sfinanci IN NUMBER, -- IAXIS-2122 -JLTS -11/02/2020
      p_parametro1 IN VARCHAR2,
      p_mv_sfinanci1   IN NUMBER,
      p_parametro2 IN VARCHAR2,
      p_mv_sfinanci2   IN NUMBER) 
      RETURN VARCHAR2;

  FUNCTION f_roles_persona(
  psperson IN NUMBER
  )   RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION f_get_tramreserva
      param in p_nsinies    : NÃºmero de siniestro
      param in CIDIOMA     : Identificador de idioma.
      param in P_TIPO    : 1 â€“ 1er Columna desc. de garantÃ­as,  textos 2- 2Âº columna,Capitales asegurados, primas,etc
      return                : Tablas de donde se obtienen los datos, por defecto POL.
   *************************************************************************/
   FUNCTION f_get_tramreserva(
      p_nsinies IN NUMBER,
      p_cidioma IN NUMBER,
      p_tipo IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION f_intermediarios
      param in p_nsinies    :
      param in CIDIOMA     :
      param in P_TIPO    :
      return                :
   *************************************************************************/

      FUNCTION f_intermediarios(
       psseguro IN  NUMBER,
       pnmovimi IN  NUMBER,
       pcolumn  IN  NUMBER,
       pmodo  IN  VARCHAR2 DEFAULT 'POL'
  )   RETURN VARCHAR2;

   /*****************************************************************
     FUNCTION f_jrep_trad
       Formatea un varchar para su visualizaciÃ³n correcta en CSVA

      param IN pentrada  : texto de entrada
      return             : texto formateado para csv
   ******************************************************************/
  FUNCTION f_jrep_trad(
      pentrada  IN  VARCHAR2
  )   RETURN VARCHAR2;


    FUNCTION f_direccion(
       p_sperson  IN  NUMBER,
       p_cdomici  IN  NUMBER,
       p_mode IN  VARCHAR2 DEFAULT 'POL'
  )   RETURN VARCHAR2;


   /*****************************************************************
   FUNCTION f_campaÃ±as
     funcion que trae datossobre las campaÃ±as:

    param IN p_tipo  : NUMBER de entrada
                    1: Nombre CampaÃ±a
                    2: Promedio
                    3: Recaudo
                    4: Siniestralidad
    param IN p_agente  : codigo agente
    param IN p_fini  : fecha ini
    param IN p_ffin  : fecha fin
    return             : texto formateado para csv
 ******************************************************************/
  FUNCTION f_campanas(
      p_tipo      IN   NUMBER,
      p_agente    IN   NUMBER,
      p_fini      IN   DATE,
      p_ffin      IN   DATE
  )   RETURN VARCHAR2;

    FUNCTION f_cumulo_persona( p_sperson  IN  NUMBER)
      RETURN NUMBER;
	  
	FUNCTION f_cumulo_dep_persona( p_sperson  IN  NUMBER)
      RETURN NUMBER;  

    FUNCTION f_per_nombre_rel (
      p_sperson  IN  NUMBER
 )   RETURN VARCHAR2;

 FUNCTION f_detallecoaseguro(
      ptipo IN NUMBER,
      pccompani IN NUMBER,
      psproces IN NUMBER,
      parama IN NUMBER,
      paramb IN NUMBER,
      paramc IN NUMBER)
      RETURN VARCHAR2;

FUNCTION f_representante_legal (psperson IN NUMBER,pdato IN NUMBER)
  RETURN VARCHAR2;

 FUNCTION f_grupo_cuentas(penviopers IN VARCHAR2, pperson IN NUMBER)
    RETURN VARCHAR2;

 FUNCTION f_num_cuenta(penviopers IN VARCHAR2, pperson IN NUMBER)
    RETURN VARCHAR2;
--
/***************************************************
 Funcion: f_per_acre_deu 
 Nombre : Persona Deudora o Acreedora
 Parametros: 
   penviopers IN VARCHAR2 envio de persona
   pperson    IN NUMBER   sperson de la persona
   return   varchar2 sperson deudor o acreedor
 TC 464 AABC 12/02/2019  VERSION 2.0        
****************************************************/
 FUNCTION f_per_acre_deu(penviopers IN VARCHAR2, pperson IN NUMBER)
    RETURN VARCHAR2;
--   

 FUNCTION f_vias_pago(penviopers IN VARCHAR2, pperson IN NUMBER)
    RETURN VARCHAR2;

  /*****************************************************************
  FUNCTION f_get_prima_minima
    FunciÃ³n que trae la prima mÃ­nima establecida por sucursal:

    param IN pcempres  : CÃ³digo de la empresa
    param IN p_agente  : CÃ³digo del agente
    param IN psproduc  : CÃ³digo del producto
    param IN pcactivi  : Código de actividad
    param IN pfbusca   : Fecha de bÃºsqueda
    return             : Prima mÃ­nima establecida
  ******************************************************************/
  FUNCTION f_get_prima_minima (
    pcempres IN  NUMBER,
    pcagente IN  NUMBER,
    psproduc IN NUMBER,
    pcactivi IN NUMBER, 
    pfbusca  IN  DATE)
  RETURN NUMBER;

  -- Ini TCS_309 - ACL - 14/03/2019
    /*************************************************************************
  FUNCTION f_cal_cuota
    FunciÃ³n que trae el valor de cuota de pagare recobros:

    param IN pscontgar  : NÃºmero de contragarantia
    return             : Valor establecido
   *************************************************************************/     
     FUNCTION f_cal_cuota(pscontgar IN NUMBER)
      RETURN NUMBER;

  /*************************************************************************
  FUNCTION f_letras_cuota
    FunciÃ³n que trae el valor en letras el valor cuota de pagare recobros:

    param IN pscontgar  : NÃºmero de contragarantia
    return             : Valor establecido
   *************************************************************************/   
    FUNCTION f_letras_cuota(pscontgar IN NUMBER)
      RETURN VARCHAR2;

  /*************************************************************************
  FUNCTION f_letras_valor1
    FunciÃ³n que trae el valor en letras del valor 1 de pagare recobros:

    param IN pscontgar  : NÃºmero de contragarantia
    return             : Valor establecido
   *************************************************************************/
   FUNCTION f_letras_valor1(pscontgar IN NUMBER)
      RETURN VARCHAR2;

  /*************************************************************************
  FUNCTION f_letras_valor2
    FunciÃ³n que trae el valor en letras del valor 2 de pagare recobros:

    param IN pscontgar  : NÃºmero de contragarantia
    return             : Valor establecido
   *************************************************************************/
   FUNCTION f_letras_valor2(pscontgar IN NUMBER)
      RETURN VARCHAR2;

  /*************************************************************************
  FUNCTION f_letras_valor3
    FunciÃ³n que trae el valor en letras del valor 1 de pagare recobros:

    param IN pscontgar  : NÃºmero de contragarantia
    return             : Valor establecido
   *************************************************************************/
   FUNCTION f_letras_valor3(pscontgar IN NUMBER)
      RETURN VARCHAR2;
  -- Fin TCS_309 - ACL - 14/03/2019  

  -- Ini TCS_309 - ACL - 18/03/2019 
      /*************************************************************************
    FUNCTION f_letras_plazo
    FunciÃ³n que trae el valor en letras del nÃºmero de cuotas:

    param IN pscontgar  : NÃºmero de contragarantia
    return             : Valor establecido
   *************************************************************************/
   FUNCTION f_letras_plazo(pscontgar IN NUMBER)
      RETURN VARCHAR2;
  -- Fin TCS_309 - ACL - 18/03/2019   

--Ini TCS_19  - ACL - 20/03/2019
    /*************************************************************************
    FUNCTION f_intermediario
    FunciÃ³n que trae el valor en letras del nÃºmero de cuotas:

    param IN pscontgar  : NÃºmero de contragarantia
    return             : Valor establecido
   *************************************************************************/
   FUNCTION f_intermediario(pscontgar IN NUMBER)
      RETURN VARCHAR2;

     /*************************************************************************
    FUNCTION f_ciud_exp_rp
    FunciÃ³n que trae el valor en letras del nÃºmero de cuotas:

    param IN pscontgar  : NÃºmero de contragarantia
    return             : Valor establecido
   *************************************************************************/ 
   FUNCTION f_ciud_exp_rp(pscontgar IN NUMBER)
      RETURN VARCHAR2;

    /*************************************************************************
    FUNCTION f_domic_rp
    FunciÃ³n que trae el valor en letras del nÃºmero de cuotas:

    param IN pscontgar  : NÃºmero de contragarantia
    return             : Valor establecido
   *************************************************************************/ 
   FUNCTION f_domic_rp(pscontgar IN NUMBER)
      RETURN VARCHAR2;
-- Fin TCS_19 - ACL - 20/03/2019 
-- Ini TCS_19 - ACL - 21/03/2019 
    /*************************************************************************
    FUNCTION f_codeudor
    FunciÃ³n que trae el valor en letras del nÃºmero de cuotas:

    param IN pscontgar  : NÃºmero de contragarantia
    return             : Valor establecido
   *************************************************************************/
   FUNCTION f_codeudor(pscontgar IN NUMBER)
      RETURN VARCHAR2;

     /*************************************************************************
    FUNCTION f_ciud_exp_cod
    FunciÃ³n que trae el valor en letras del nÃºmero de cuotas:

    param IN pscontgar  : NÃºmero de contragarantia
    return             : Valor establecido
   *************************************************************************/ 
   FUNCTION f_ciud_exp_cod(pscontgar IN NUMBER)
      RETURN VARCHAR2;

    /*************************************************************************
    FUNCTION f_domic_cod
    FunciÃ³n que trae el valor en letras del nÃºmero de cuotas:

    param IN pscontgar  : NÃºmero de contragarantia
    return             : Valor establecido
   *************************************************************************/ 
   FUNCTION f_domic_cod(pscontgar IN NUMBER)
      RETURN VARCHAR2;

-- Fin TCS_19 - ACL - 21/03/2019 

-- Cambios de IAXIS-3286 : start
  /*************************************************************************
    FUNCTION f_roles_persona_Bridger
    FunciÃ³n que trae el vÃ­nculo del tercero:

    param
     IN psperson     : NÃºmero de persona
     IN pctipper_rel : tipo de relacion para persona
    return           : El vÃ­nculo del tercero
   *************************************************************************/  
  FUNCTION f_roles_persona_Bridger(
    psperson IN NUMBER,
    pctipper_rel in number
  )RETURN VARCHAR2;
  -- Cambios de IAXIS-3286 : end

  -- Ini IAXIS-2136 - ACL - 28/03/2019
     /*************************************************************************
    FUNCTION f_documento_nit
    Funcion que retorna el numero de documento de identidad con o sin digiro de verificacion si aplica

    param IN psseguro  : identificador unico
    return             : Valor establecido
   *************************************************************************/     
    FUNCTION f_documento_nit(
      p_sperson IN NUMBER,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2;

  /*************************************************************************
    FUNCTION f_dig_verif_nit
    Funcion que retorna el digito de verificacion cuando es NIT 

    param IN psseguro  : identificador unico
    return             : Valor establecido
   *************************************************************************/     
    FUNCTION f_dig_verif_nit(
      p_sperson IN NUMBER,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2;

  /*************************************************************************
    FUNCTION f_trm_caratula
    Funcion que retorna TRM caratula de poliza

    param IN psseguro  : identificador unico
    param IN pnmovimi  : numero de movimiento
    return             : Valor establecido
   *************************************************************************/     
    FUNCTION f_trm_caratula(
      p_sseguro IN NUMBER, 
      p_nmovimi IN NUMBER)
      RETURN NUMBER;

  /*************************************************************************
    FUNCTION f_texto_clausula
    Funcion que retorna texto de caratula

    param IN psseguro  : identificador unico
    return             : Valor establecido
   *************************************************************************/          
    FUNCTION f_texto_clausula ( 
        psseguro   IN NUMBER ) 
    RETURN VARCHAR2;

  /*************************************************************************
    FUNCTION f_texto_formato
    Funcion que retorna texto de caratula

    param IN psseguro  : identificador unico
    return             : Valor establecido
   *************************************************************************/      
    FUNCTION f_texto_formato ( 
        psseguro   IN NUMBER ) 
    RETURN VARCHAR2;
-- Fin IAXIS-2136 - ACL - 28/03/2019

-- Ini IAXIS-2136 - ACL - 03/04/2019
  /*************************************************************************
    FUNCTION f_nombre_beneficiario
    Funcion que retorna el nombre del beneficiario

    param IN psseguro  : identificador unico
    return             : Valor establecido
   *************************************************************************/     
    FUNCTION f_nombre_beneficiario ( 
        psseguro   IN NUMBER ) 
    RETURN VARCHAR2;
    
     /*************************************************************************
    FUNCTION f_ident_beneficiario
    Funcion que retorna el numero de identificacion del beneficiario

    param IN psseguro  : identificador unico
    return             : Valor establecido
   *************************************************************************/  
   
    FUNCTION f_ident_beneficiario ( 
        psseguro   IN NUMBER ) 
    RETURN VARCHAR2;
    
     /*************************************************************************
    FUNCTION f_dv_beneficiario
    Funcion que retorna el digito de verificacion de la identificacion del beneficiario

    param IN psseguro  : identificador unico
    return             : Valor establecido
   *************************************************************************/  
   
    FUNCTION f_dv_beneficiario ( 
        psseguro   IN NUMBER ) 
    RETURN NUMBER;
    
    /*************************************************************************
    FUNCTION f_dir_beneficiario
    Funcion que retorna la direccion del beneficiario

    param IN psseguro  : identificador unico
    return             : Valor establecido
   *************************************************************************/  
   
   FUNCTION f_dir_beneficiario ( 
        psseguro   IN NUMBER )
    RETURN VARCHAR2; 
    
    /*************************************************************************
    FUNCTION f_ciudad_benef
    Funcion que retorna la ciudad del beneficiario

    param IN psseguro  : identificador unico
    return             : Valor establecido
   *************************************************************************/  
   
   FUNCTION f_ciudad_benef ( 
        psseguro   IN NUMBER) 
    RETURN VARCHAR2;
    
       /*************************************************************************
    FUNCTION f_tel_beneficiario
    Funcion que retorna el telefono del beneficiario

    param IN psseguro  : identificador unico
    return             : Valor establecido
   *************************************************************************/  
   
   FUNCTION f_tel_beneficiario ( 
        psseguro   IN NUMBER) 
    RETURN VARCHAR2;
-- Fin IAXIS-2136 - ACL - 03/04/2019

-- Ini IAXIS-2136 - ACL - 05/04/2019
    /*************************************************************************
    FUNCTION f_datos_abogado
    Funcion que retorna los datos del abogado para el producto caucion judicial 

    param IN psseguro  : identificador unico
    return             : Valor establecido
   *************************************************************************/  
   FUNCTION f_datos_abogado ( 
        psseguro   IN NUMBER) 
    RETURN VARCHAR2;
    
    /*************************************************************************
    FUNCTION f_datos_juzgado
    Funcion que retorna los datos del juzgado para el producto caucion judicial 

    param IN psseguro  : identificador unico
    return             : Valor establecido
   *************************************************************************/  
   FUNCTION f_datos_juzgado ( 
        psseguro   IN NUMBER) 
    RETURN VARCHAR2;

   /*************************************************************************
    FUNCTION f_datos_art_cj
    Funcion que retorna los datos del artículo para el producto caucion judicial 

    param IN psseguro  : identificador unico
    return             : Valor establecido
   *************************************************************************/  
   FUNCTION f_datos_art_cj ( 
        psseguro   IN NUMBER) 
    RETURN VARCHAR2;  
-- Fin IAXIS-2136 - ACL - 05/04/2019

-- Ini IAXIS-2136 - ACL - 06/05/2019
    /*************************************************************************
    FUNCTION f_tex_clausulado
    Funcion que retorna TRM caratula de poliza

    param IN psseguro  : identificador unico
    param IN pnmovimi  : numero de movimiento
    return             : Valor establecido
   *************************************************************************/ 
   FUNCTION f_tex_clausulado(
      p_sseguro IN NUMBER)
      RETURN VARCHAR2;
      
    /*************************************************************************
    FUNCTION f_texto_exclusion
    Funcion que retorna texto de exclusion en una caratula

    param IN psseguro  : identificador unico
    return             : Valor establecido
   *************************************************************************/ 
    FUNCTION f_texto_exclusion ( 
        psseguro   IN NUMBER ) 
    RETURN VARCHAR2; 
	-- Fin IAXIS-2136 - ACL - 06/05/2019
	
	-- Ini IAXIS-2136 - ACL - 09/05/2019
	/*************************************************************************
    FUNCTION f_valor_iva_pesos
    Funcion que retorna TRM caratula de poliza

    param IN psseguro  : identificador unico
    param IN pnmovimi  : numero de movimiento
    return             : Valor establecido
   *************************************************************************/     
    FUNCTION f_valor_iva_pesos(
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER)
      RETURN NUMBER;
	-- Fin IAXIS-2136 - ACL - 09/05/2019
	
-- Ini IAXIS-3656 - ACL - 10/05/2019
  /*************************************************************************
    FUNCTION f_tip_movim
    Funcion que retorna la abreviatura del tipo de movimiento

    param IN psseguro  : identificador unico
    return             : Valor establecido
   *************************************************************************/ 
    FUNCTION f_tip_movim ( 
        psseguro   IN NUMBER,
        pnmovimi   IN NUMBER) 
    RETURN VARCHAR2;
	
	/*************************************************************************
    FUNCTION f_delega
    Funcion que retorna si esusuario interno o externo

    param IN psseguro  : identificador unico
    param IN pnmovimi  : numero de movimiento
    return             : Valor establecido
   *************************************************************************/      
   FUNCTION f_delega ( 
        psseguro   IN NUMBER) 
    RETURN VARCHAR2;
    -- Fin IAXIS-3656 - ACL - 10/05/2019

    -- INI IAXIS-3750 - RABQ
  
    FUNCTION f_distrib_cum_rea(
        psperson IN VARCHAR2,
        pparam IN NUMBER)
    RETURN NUMBER;
  
    -- FIN IAXIS-3750 - RABQ
	
	-- Ini IAXIS-2136 - ACL - 14/05/2019
	/*************************************************************************
    FUNCTION f_agente_new
    Funcion que retorna la sucursal

    param IN pcagente  : identificador unico
    param IN pctipage  : tipo de agente
    return             : Valor establecido
   *************************************************************************/  
    FUNCTION f_agente_new(pcagente IN NUMBER,
        pctipage IN NUMBER)
      RETURN VARCHAR;
	-- Fin IAXIS-2136 - ACL - 14/05/2019
	
	-- inicio IAXIS-4207 - ACL - 04/06/2019 guilherme
	/*************************************************************************
    FUNCTION F_AGENTE_BLOCK
    Funcion que retorna 1 si el agente esta bloqueado por persona, 2 si esta bloqueado por codigo o 0 si esta bien

    param IN pcagente  : codigo del agente
    return             : number
   *************************************************************************/  
   FUNCTION F_AGENTE_BLOCK (pcagente   IN NUMBER) 
    RETURN NUMBER;  
-- Fin IAXIS-4207 - ACL - 04/06/2019 guilherme 

 /*************************************************************************
      FUNCTION f_get_reservatramita
      param in p_nsinies    : numero de siniestro
      param in CIDIOMA     : Identificador de idioma.
      param in P_TIPO    : 1 sirve  para retornar ya sea Importe Coste, Importe reservas, Imp.pago, Imp. Recobro
   *************************************************************************/
   FUNCTION f_get_reservatramita(
      p_nsinies IN NUMBER,
      p_cidioma IN NUMBER,
      p_tipo IN NUMBER)
      RETURN VARCHAR2;
   --bug 4167  - 11/06/2019
   
   /*************************************************************************
      FUNCTION f_get_maximapp
      param in p_nsinies    : numero de siniestro
      param in P_TIPO    : 1 sirve  para retornar ya sea la maxima perdida probable, la contingencia o el riesgo
   *************************************************************************/
   FUNCTION f_get_maximapp(
      p_nsinies IN NUMBER,
      p_tipo IN NUMBER)
      RETURN VARCHAR2;
   --bug 4167  - 06/25/2019
   
    /*************************************************************************
      FUNCTION f_get_estadocartera
      param in p_nsinies    : numero de siniestro
   *************************************************************************/
   FUNCTION f_get_estadocartera(
      p_sseguro IN NUMBER)
      RETURN VARCHAR2;
   --bug 4167  - 06/25/2019

 /*************************************************************************
      FUNCTION f_nom_nit_pagare
      param in p_nsinies    : numero de siniestro
      funcionalidad   : para el reporte de pagare, personas que conforman consorcio

   *************************************************************************/
   FUNCTION f_nom_nit_pagare(
      pnsinies IN NUMBER)
      RETURN VARCHAR2;
   -- Fin  bug 2485

    --tarea 4196 inicio 22/07/2019 André Pfeiffer
   /*************************************************************************
    FUNCTION f_texto_exclusion_rc
    Funcion que retorna texto de exclusion en una caratula R.C.

    param IN psseguro  : identificador unico
    param IN pcampo    : la ordem de lo texto (se es lo primeir o segundo campo)
    return             : Valor establecido
   *************************************************************************/ 
    FUNCTION f_texto_exclusion_rc ( 
        psseguro   IN NUMBER,
        pcampo   IN NUMBER) 
    RETURN VARCHAR2;
    --tarea 4196 inicio 22/07/2019 André Pfeiffer
	
	
	FUNCTION f_texto_clau_caratula (psseguro IN NUMBER, pnmovimi IN NUMBER, ptipo IN NUMBER) RETURN VARCHAR2;
	
	FUNCTION f_get_ultmov( PSSEGURO IN NUMBER, PTIPO IN NUMBER DEFAULT 2) RETURN NUMBER;

END pac_isqlfor_conf;
/