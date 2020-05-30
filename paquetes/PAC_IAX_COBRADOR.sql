--------------------------------------------------------
--  DDL for Package PAC_IAX_COBRADOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_COBRADOR" IS
/******************************************************************************
   NOMBRE:       pac_iax_cobrador
   PROPÓSITO: Package para el mantenimiento de cobradores bancarios.

   REVISIONES:

   Ver        Fecha        Autor      Descripción
   ---------  ----------  ------      ------------------------------------
     1        29/09/2010   ICV        1. Creación del package
     2        22/09/2014   CASANCHEZ  2. 0032668: COLM004-Trapaso entre Bancos (cobrador bancario) manteniendo la nómina
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*****************************************************************************
        Función que selecciona todos los cobradores que cumplan con los parámetros de entrada de la consulta.
        PCEMPRES: Código de la empresa.
        PCCOBBAN: Número de cobrador.
        PCTIPBAN: Código tipo de cuenta
        PCDOMENT: Código de la Entidad
        PTSUFIJO: Sufijo asignado a la norma 19
        PCDOMSUC: Código Sucursal
        PCRAMO: Ramo
        PCMODALI: Modalidad
        PCCOLECT: Colectividad
        PCTIPSEG: Tipo de seguro
        PCAGENTE: Mediador
        PCBANCO: Código Banco
        param in out  : MENSAJES Missatges de sortida.
   *****************************************************************************/
   FUNCTION f_get_cobrador(
      pcempres IN NUMBER,
      pccobban IN NUMBER,
      pctipban IN NUMBER,
      pcdoment IN NUMBER,
      ptsufijo IN VARCHAR2,
      pcdomsuc IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcagente IN NUMBER,
      pcbanco IN NUMBER,
      pncuenta IN VARCHAR2,
      pcobrador OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*****************************************************************************
        Función que selecciona todos los cobradores que cumplan con los parámetros de entrada de la consulta.
        PCCOBBAN: Número de cobrador.
        param in out  : MENSAJES Missatges de sortida.
   *****************************************************************************/
   FUNCTION f_get_cobrador_det(
      pccobban IN NUMBER,
      pobjban OUT t_iax_cobbancario,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

    /*****************************************************************************
        Función que selecciona la información de la selección del cobrador para uno en concreto.
        PCCOBBAN: Número de cobrador.
        param in out  : MENSAJES Missatges de sortida.
   *****************************************************************************/
   FUNCTION f_get_cobrador_sel(
      pccobban IN NUMBER,
      pnorden IN NUMBER,
      pccobbansel OUT t_iax_cobbancariosel,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
       Nueva función que actualiza la información introducida o modificada del cobrador bancario.
       param pcempres    in : Código de la empresa.
       param PCCOBBAN    IN : Número de cobrador.
       param PCTIPBAN    IN : Código tipo de cuenta
       param PCDOMENT    IN : Código de la Entidad
       param PTSUFIJO    IN : Código Sucursal
       param PNCUENTA    IN : Número de cuenta
       param PCBAJA    IN : Código de baja
       param PCESCRIPCION    IN : Descripción
       param PNNUMNIF    IN : nif
       param CCONTABAN:  Código contable para el cobrador bancario
       param DOM_FILLER_LN3:  Filler para las líneas '3' del fichero de domiciliación
       retorno 0-Correcto, 1-Código error.
   *************************************************************************/
   FUNCTION f_set_cobrador(
      pccobban IN NUMBER,
      pncuenta IN VARCHAR2,
      ptsufijo IN VARCHAR2,
      pcempres IN NUMBER,
      pcdoment IN NUMBER,
      pcdomsuc IN NUMBER,
      pnprisel IN NUMBER,
      pcbaja IN NUMBER,
      pdescrip IN VARCHAR2,
      pnnumnif IN VARCHAR2,
      ptcobban IN VARCHAR2,
      pctipban IN NUMBER,
      pccontaban IN NUMBER,
      pdomfill3 IN VARCHAR2,
      pcmodo IN VARCHAR2,
      pprecimp IN NUMBER,
      pcagruprec IN NUMBER,   -- Bug 19986 - APD - 08/11/2011 - se añade el campo cagruprec
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
         Nueva función que actualiza la información introducida o modificada del cobrador bancario.
         param PCCOBBAN    IN : Número de cobrador.
         param PNORDEN    in : Orden prioridad de selección
         param pcempres    in : Código de la empresa.
         param PCRAMO    IN : Ramo
         param PCMODALI    IN : Modalidad
         param PCTIPSEG    IN : Tipo de seguro
         param PCCOLECT    IN : Colectividad
         param PCBANCO    IN : Código Banco
         param PCTIPAGE    IN : Tipo mediador
         param PCAGENTE    IN :  Mediador
         retorno 0-Correcto, 1-Código error.
     *************************************************************************/
   FUNCTION f_set_cobrador_sel(
      pccobban IN NUMBER,
      pnorden IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcempres IN NUMBER,
      pcbanco IN NUMBER,
      pcagente IN NUMBER,
      pctipage IN NUMBER,
      pcmodo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

    /*************************************************************************
         Nueva función que retorna un número nuevo de cobrador
   ***************************************************************************/
   FUNCTION f_get_noucobrador(pccobban OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
     Nueva función que retorna la descripción de un banco
     retorno 0-Correcto, 1-Código error.
   *************************************************************************/
   FUNCTION f_get_desbanco(
      pcbanco IN NUMBER,
      ptbanco OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
     Nueva función que reasliza el traspaso de bancos
     param pcempresa      IN  codigo de la empresa
     param pcobbanorigen  IN  cobrador bancario origen
     param pcbanco        IN  codigo de banco a trapasar
     param pcobbandestino IN  cobrador destino
     param mensajes       OUT mensaje de error
     retorno 0-Correcto, 1-Código error.
    *************************************************************************/
   FUNCTION f_traspaso_cobradores(
      pcempresa IN empresas.cempres%TYPE,
      pcobbanorigen IN cobbancario.ccobban%TYPE,
      pcbanco IN bancos.cbanco%TYPE,
      pcobbandestino IN cobbancario.ccobban%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
--
END pac_iax_cobrador;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_COBRADOR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_COBRADOR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_COBRADOR" TO "PROGRAMADORESCSI";
