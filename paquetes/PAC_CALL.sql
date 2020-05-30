--------------------------------------------------------
--  DDL for Package PAC_CALL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CALL" AS
/******************************************************************************
   NOMBRE:      pac_call
   PROPÓSITO:  Interficie para cada tipo de suplemento desde la capa de negocio

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        28/07/2009   JRH                1. Creación del package. Bug 10776 reducción total
   2.0        15/09/2010   JRH                2. 0012278: Proceso de PB para el producto PEA.
   3.0        19/10/2011   RSC                3. 0019412: LCOL_T004: Completar parametrización de los productos de Vida Individual
   4.0        16/01/2012   APD                4. 0020671: LCOL_T001-LCOL - UAT - TEC: Contratacion
   5.0        28/06/2012   FAL                5.0021905: MDP - TEC - Parametrización de productos del ramo de Accidentes - Nueva producción
   6.0        22/01/2013   JMF                0025815: LCOL: Cambios para Retorno seg?n reuni?n con Comercial
   7.0        25/02/2013   DCT                7. 0025965  0025965: LCOL - AUT - Listas Restringidas para placas
   8.0        07/05/2014   ECP                8. 31204/0012459: Error en beneficiarios al duplicar Solicitudes
******************************************************************************/

   /*************************************************************************
      Realiza la reducción total de una póliza
      param in psseguro   : Número de seguro
      param in pfefecto   : Fecha del suplemento (puede ser nula, si es asi pondremos la del ultimo suplemento)
      return              : 0 todo correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_reduccion_total(psseguro IN NUMBER, pfefecto IN DATE DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
      F_APERTURA_SINIESTRO
      Función que sirve para aperturar un siniestro con su tramitación y reserva inicial pendiente.
        1.  PSPRODUC: Tipo numérico. Parámetro de entrada. Identificador del producto
        2.  PSSEGURO: Tipo numérico. Parámetro de entrada. Código de póliza.
        3.  PNRIESGO: Tipo numérico. Parámetro de entrada. Número de riesgo.
        4.  PCACTIVI: Tipo numérico. Parámetro de entrada. Identificador de activivad.
        5.  PFSINIES: Tipo Fecha. Parámetro de etnrada. Fecha de siniestro. Desde traspasos se llamará con la fecha de efecto del traspaso
        6.  PFNOTIFI: Tipo Fecha. Parámetro de entrada. Fecha de notificación del siniestro. Desde traspasos se llamará con la fecha de aceptación del traspaso.
        7.  PCCAUSIN:Tipo numérico. Parámetro de entrada. Código de causa del siniestro
        8.  PCMOTSIN:  Tipo numérico. Parámetro de entrada. Código de motivo del siniestro
        9.  PTSINIES: Tipo carácter. Parámetro de entrada.
        10. PTZONAOCU: Tipo carácter. Parámetro de entrada.
        11. PCGARANT: Tipo numérico. Parámetro de entrada. Garantía asignada al traspaso
        12. PITRASPASO: Tipo numérico. Parámetro de entrada. Importe del traspaso.

        Retorna un valor numérico: 0 si se ha aperturado el siniestro y un código de error correspondiente si ha habido un error.
   *************************************************************************/
   FUNCTION f_apertura_siniestro(
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcactivi IN NUMBER,
      pfsinies IN DATE,
      pfnotifi IN DATE,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER,
      ptsinies IN VARCHAR2,
      ptzonaocu IN VARCHAR2,
      pcgarant IN NUMBER,
      pitraspaso IN NUMBER,
      pnsinies IN OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_pago_i_cierre_sin(
      pnsinies IN NUMBER,
      xproduc IN NUMBER,
      xcactivi IN NUMBER,
      psidepag IN NUMBER)
      RETURN NUMBER;

   -- BUG 12278 -  09/2010 - JRH  - 0012278: Proceso de PB para el producto PEA.

   /*************************************************************************
      f_suplemento_garant
      Realiza un suplemento asociado a garnatía (PB, Aport ext.,..)
      param in psseguro   : Número de seguro
      param in pnriesgo   : Riesgo
      param in pfecha   : Fecha del suplemento
      param in pimporte   : Importe
      param in pctipban   : Tipo banc.
      param in pcbancar   : Cuenta
      param in pcgarant   : Garantía asociada al suplemento
      param out           : pnmovimi
      return              : 0 todo correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_suplemento_garant(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfecha IN DATE,
      pimporte IN NUMBER,
      pctipban IN NUMBER,
      pcbancar IN VARCHAR2,
      pcgarant IN NUMBER,
      pnmovimi OUT NUMBER)
      RETURN NUMBER;

-- Fi BUG 12278 -  09/2010 - JRH

   /*************************************************************************
      f_datos_tomador
      Obtener algunos datos del tomador del objeto
      pnregistro in number: Numero de registro que queremos obtener
      psperson out number:  secuencia persona
      pctipper out number: tipo de persona
      pctipide out number: tipo identificacion
      pnnumide out varchar2: numero identificacion
      ptapelli1 out varchar2: primer apellido
      ptapelli2 out varchar2: segundo apellido
      ptnombre1 out varchar2: primer nombre
      ptnombre2 out varchar2: segundo nombre
      return              : 0 todo correcto, 1 ha habido un error
   *************************************************************************/
   -- BUG 0018967 - 07/09/2011 - JMF
   FUNCTION f_datos_tomador(
      pnregistro IN NUMBER,
      psperson OUT NUMBER,
      pctipper OUT NUMBER,
      pctipide OUT NUMBER,
      pnnumide OUT VARCHAR2,
      ptapelli1 OUT VARCHAR2,
      ptapelli2 OUT VARCHAR2,
      ptnombre1 OUT VARCHAR2,
      ptnombre2 OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
      f_datos_asegurado
      Obtener algunos datos del asegurado del objeto
      pnregistro in number: Numero de registro que queremos obtener
      psperson out number:  secuencia persona
      pctipper out number: tipo de persona
      pctipide out number: tipo identificacion
      pnnumide out varchar2: numero identificacion
      ptapelli1 out varchar2: primer apellido
      ptapelli2 out varchar2: segundo apellido
      ptnombre1 out varchar2: primer nombre
      ptnombre2 out varchar2: segundo nombre
      return              : 0 todo correcto, 1 ha habido un error
   *************************************************************************/
   -- BUG 0018967 - 07/09/2011 - JMF
   FUNCTION f_datos_asegurado(
      pnregistro IN NUMBER,
      psperson OUT NUMBER,
      pctipper OUT NUMBER,
      pctipide OUT NUMBER,
      pnnumide OUT VARCHAR2,
      ptapelli1 OUT VARCHAR2,
      ptapelli2 OUT VARCHAR2,
      ptnombre1 OUT VARCHAR2,
      ptnombre2 OUT VARCHAR2,
      pcsexper OUT NUMBER)   -- BUG 21905 - FAL - 27/06/2012
      RETURN NUMBER;

   -- Bug 19412/95066 - RSC - 19/10/2011
   FUNCTION f_get_persona_tomador(
      pnregistro IN NUMBER,
      psperson OUT NUMBER,
      pcpais OUT NUMBER,
      pnacionalidad OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_get_persona_asegurado(
      pnregistro IN NUMBER,
      psperson OUT NUMBER,
      pcpais OUT NUMBER,
      pnacionalidad OUT NUMBER)
      RETURN NUMBER;

-- Bug 19412/95066
   FUNCTION f_valida_beneficiario(pnriesgo IN NUMBER, pvalida OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      f_get_preguntas
      Obtener las preguntas de poliza del objeto
      pnregistro in number: Numero de registro que queremos obtener
      pcpregun in out number: codigo de la pregunta
      pcrespue out number: respuesta de la pregunta
      pexistepreg out number: indica si existe o no la pregunta (0.-No existe, 1.-Si existe)
      return              : 0 todo correcto, 1 ha habido un error
   *************************************************************************/
   -- BUG 20671 - 16/01/2012 - APD
   FUNCTION f_get_preguntas(
      pnregistro IN NUMBER,
      pcpregun IN OUT NUMBER,
      pcrespue OUT NUMBER,
      ptrespue OUT VARCHAR2,
      pexistepreg OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      f_persona_asegurado
      Obtener algunos datos del asegurado del objeto
      pnregistro in number: Numero de registro que queremos obtener
      psperson out number:  secuencia persona
      pfnacimi out date: fecha de nacimiento
      return              : 0 todo correcto, 1 ha habido un error
   *************************************************************************/
   -- Bug 20671 - RSC - LCOL_T001-LCOL - UAT - TEC: Contratación
   FUNCTION f_persona_asegurado(pnregistro IN NUMBER, psperson OUT NUMBER, pfnacimi OUT DATE)
      RETURN NUMBER;

   FUNCTION f_valor_asegurado_basica(
      pnriesgo IN NUMBER,
      pcgardep IN NUMBER,
      pcpregun IN NUMBER,
      pcvalor OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      f_datos_tomador
      Obtener algunos datos del seguro del objeto
      pcagente out number: codigo agente
      psproduc out number: secuencia del producto
      pfefecto out date: fecha de efecto
      pnpoliza out number: numero poliza
      pncertif out number: numero certificado
      return              : 0 todo correcto, 1 ha habido un error
   *************************************************************************/
   -- BUG 0025815 - 22/01/2013 - JMF
   FUNCTION f_datos_seguro(
      pcagente OUT NUMBER,
      psproduc OUT NUMBER,
      pfefecto OUT DATE,
      pnpoliza OUT NUMBER,
      pncertif OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
        f_get_pregungaran
        Obtener las preguntas de garantia de poliza del objeto
        pcgarant in number: Garantia a la que pertenece la pregunta
        pcpregun in out number: codigo de la pregunta
        pcrespue out number: respuesta de la pregunta
       pexistepreg out number: indica si existe o no la pregunta (0.-No existe, 1.-Si existe)
        return              : 0 todo correcto, 1 ha habido un error
     *************************************************************************/-- BUG 20671 - 16/01/2012 - APD
   FUNCTION f_get_pregungaran(
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pcpregun IN NUMBER,
      pcrespue OUT pregungaranseg.crespue%TYPE,
      ptrespue OUT pregungaranseg.trespue%TYPE)
      RETURN NUMBER;

    /*************************************************************************
      f_datos_conductor
      Obtener algunos datos del conductor del objeto
      pnregistro in number: Numero de registro que queremos obtener
      psperson out number:  secuencia persona
      pctipper out number: tipo de persona
      pctipide out number: tipo identificacion
      pnnumide out varchar2: numero identificacion
      ptapelli1 out varchar2: primer apellido
      ptapelli2 out varchar2: segundo apellido
      ptnombre1 out varchar2: primer nombre
      ptnombre2 out varchar2: segundo nombre
      return              : 0 todo correcto, 1 ha habido un error
   *************************************************************************/
   -- BUG 0025965- 25/02/2013 - DCT
   FUNCTION f_datos_conductor(
      pnregistro IN NUMBER,
      psperson OUT NUMBER,
      pctipper OUT NUMBER,
      pctipide OUT NUMBER,
      pnnumide OUT VARCHAR2,
      ptapelli1 OUT VARCHAR2,
      ptapelli2 OUT VARCHAR2,
      ptnombre1 OUT VARCHAR2,
      ptnombre2 OUT VARCHAR2,
      pcsexper OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      f_garantias_siniestro
      Obtener las garantias seleccionadas para el siniestro del objeto
      ptgarantias out t_iax_garansini:  garantias seleccionadas
      return              : 0 todo correcto, 1 ha habido un error
   *************************************************************************/-- BUG 0025607 - 25/04/2013 - DCT
   FUNCTION f_garantias_siniestro(ptgarantias OUT t_iax_garansini)
      RETURN NUMBER;

   /*************************************************************************
      f_get_parpersona
      Obtener los parametros de la persona

      return              : 0 todo correcto, 1 ha habido un error

      Bug 27314/158946 - 18/11/2013 - AMC
   *************************************************************************/
   FUNCTION f_get_parpersona(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcvisible IN NUMBER,
      ptots IN NUMBER,
      pctipper IN NUMBER,
      pparper OUT t_iax_par_personas)
      RETURN NUMBER;

   /*************************************************************************
      f_abrir_suplemento
      Abrir suplemento

      return              : 0 todo correcto, 1 ha habido un error

      Bug 26472/169132 - 11/03/2014 - NSS
   *************************************************************************/
   FUNCTION f_abrir_suplemento(psseguro IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      f_emitir_col_admin
      Emitir colectivo administrado

      return              : 0 todo correcto, 1 ha habido un error

      Bug 26472/169132 - 11/03/2014 - NSS
   *************************************************************************/
   FUNCTION f_emitir_col_admin(psseguro IN NUMBER)
      RETURN NUMBER;
END pac_call;

/

  GRANT EXECUTE ON "AXIS"."PAC_CALL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CALL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CALL" TO "PROGRAMADORESCSI";
