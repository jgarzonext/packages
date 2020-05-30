--------------------------------------------------------
--  DDL for Package PAC_MD_SUP_FINAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_SUP_FINAN" AS
/******************************************************************************
   NOMBRE:       PAC_MD_SUP_FINAN
   PROPÓSITO:  Funciones de suplementos para productos financieros

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        25/03/2008   JRH                1. Creación del package.
   2.0        11/11/2009   JRB                2. Se añade ctipban a la aportación
   3.0        25/05/2010   JMF                3. 0014185 ENSA101 - Proceso de carga del fichero (beneficio definido)
******************************************************************************/
   FUNCTION iniciarsuple
      RETURN NUMBER;

   --JRH 03/2008
   /*************************************************************************
      Valida y realiza una aportación extraordinaria
      param in psseguro  : póliza
      param in pnriesgo  : riesgo
      param in fecha     : fecha de la aportación
      pimporte           : Importe de la aportación
      pctipban           : Tipo de cuenta.
      pcbancar           : Cuenta bancaria.
      param out mensajes : mensajes de error
      pcommit            : (1) Guardar (valor per defecte), (0) No guardar.
      pctipapor in       : Tipo de aportación
      psperapor in       : Persona aportante
      ptipoaportante in  : Tipo de aportante
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   -- Bug 0014185 - JMF - 25/05/2010: Añadir parametro pcommit
   FUNCTION f_aportacion_extraordinaria(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      fecha IN DATE,
      pimporte IN NUMBER,
      pctipban IN NUMBER,
      pcbancar IN VARCHAR2,
      pcgarant IN NUMBER,
      pnmovimi OUT NUMBER,
      mensajes OUT t_iax_mensajes,
      pcommit IN NUMBER DEFAULT 1,
      pctipapor IN NUMBER DEFAULT NULL,
      psperapor IN NUMBER DEFAULT NULL,
      pcobrorec IN NUMBER DEFAULT 1,
      pccobban IN NUMBER DEFAULT NULL,
      ptipoaportante IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

/*************************************************************************
       Tarifica una aportación extraordinaria
       param in psseguro  : póliza
       param in pnriesgo  : riesgo
       param in fecha     : fecha de la aportación
       pimporte           : Importe de la aportación
       capitalGaran out number  : Capital garantizado en el suplemento
       param out mensajes : mensajes de error
       return             : 0 todo correcto
                            1 ha habido un error
    *************************************************************************/
   FUNCTION f_tarif_aport_extraordinaria(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      fecha IN DATE,
      pimporte IN NUMBER,
      pcgarant IN NUMBER,
      capitalgaran OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
       Inserta la Participación de Benificios en CTASEGURO después de completar su suplemento (ya que no se genra recibo).
       param in psseguro  : póliza
       return             : 0 todo correcto
                            1 ha habido un error
    *************************************************************************/
   FUNCTION f_insert_ctaseg(psseguro IN NUMBER)
      RETURN NUMBER;

   --Bug.: 18632 - ICV - 06/06/2011

   /*************************************************************************
   param in psseguro  : póliza
   param out mensajes : mensajes de error
   return             : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_aportantes(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   param in pctipoapor  : Tipo Aportante
   param in sseguro : Identificador del seguro
   param out psperapor  : Sperson del aportante
   param out pcagente  : Cagente del aportante
   param out mensajes : mensajes de error
   return             : 0 correcto 1 error
   *************************************************************************/
   FUNCTION f_get_infoaportante(
      pctipapor IN NUMBER,
      psseguro IN NUMBER,
      psperapor OUT NUMBER,
      pcagente OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
--Fi Bug.: 18632
END pac_md_sup_finan;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_SUP_FINAN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SUP_FINAN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SUP_FINAN" TO "PROGRAMADORESCSI";
