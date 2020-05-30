--------------------------------------------------------
--  DDL for Package PK_TRANSFERENCIAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PK_TRANSFERENCIAS" AUTHID CURRENT_USER AS
/******************************************************************************
   NOM:       pk_transferencias

   REVISIONS:
   Ver        Fecha       Autor  Descripción
   ---------  ----------  -----  ------------------------------------
   1.0                           Creación del package.
   2.0        02/07/2009  DRA    0010604: Nuevo control Reembolsos - Pago Retenido
   3.0        29/07/2009  APD    0010775: Modificación fichero de transferencias para reembolsos
******************************************************************************//*
   Funcion que inserta en la tabla de remesas todos los casos transferibles,
   siniestros , rescates, rentas o recibos de extorno
   */
   FUNCTION f_insert_remesas(
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      psremisesion IN NUMBER,   -- Identificador de la sesion de inserciones de la remesa
      pprestacion IN NUMBER DEFAULT 0,
      tipproceso IN NUMBER DEFAULT 0,   --tipProceso: 0-todos 1- Rentas 2- recibos 3- siniestros
      pagrup IN NUMBER DEFAULT NULL,   --Agrupación
      pcausasin IN NUMBER DEFAULT NULL   --En el caso de siniestros, la causa del siniestro
                                      )
      RETURN NUMBER;

   /*
   Funcion que se encarga de tratar todos los casos seleccionados en la tabla remesas,
   actualizado estado de recibos a tranferidos....
   */
   FUNCTION f_transferir(
      pcempres IN NUMBER,
      psremisesion IN NUMBER,   -- Identificador de la sesion de inserciones de la remesa
      pnremesa OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_generacion_fichero(pnremesa IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_generacion_fichero_iban(pnremesa IN NUMBER)
      RETURN NUMBER;

   /* funcion que genera el fichero para una remesa específica*/
   FUNCTION f_generar_fichero(pnremesa IN NUMBER, p_formato VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

   /* JRH 11/2007 funcion que inserta en ctaseguro para rentas*/
   FUNCTION insertar_ctaseguro(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pnnumlin IN NUMBER,
      pffecmov IN DATE,
      pffvalmov IN DATE,
      pcmovimi IN NUMBER,
      pimovimi IN NUMBER,
      pimovimi2 IN NUMBER,
      pnrecibo IN NUMBER,
      pccalint IN NUMBER,
      pcmovanu IN NUMBER,
      pnsinies IN NUMBER,
      psmovrec IN NUMBER,
      pcfeccob IN NUMBER,
      --vienen de fmovcta
      pfmovini IN DATE,
      pfmovdia IN DATE DEFAULT NULL,
      psrecren IN NUMBER DEFAULT NULL)   --JRH Id pago de renta
      RETURN NUMBER;

   FUNCTION insertar_ctaseguro_shw(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pnnumlin IN NUMBER,
      pffecmov IN DATE,
      pffvalmov IN DATE,
      pcmovimi IN NUMBER,
      pimovimi IN NUMBER,
      pimovimi2 IN NUMBER,
      pnrecibo IN NUMBER,
      pccalint IN NUMBER,
      pcmovanu IN NUMBER,
      pnsinies IN NUMBER,
      psmovrec IN NUMBER,
      pcfeccob IN NUMBER,
      --vienen de fmovcta
      pfmovini IN DATE,
      pfmovdia IN DATE DEFAULT NULL,
      psrecren IN NUMBER DEFAULT NULL)   --JRH Id pago de renta
      RETURN NUMBER;

   --Traspasamos pagos de rentas pdtes. a día de hoy
   FUNCTION f_traspasar_rentas(
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      ptipoproceso IN NUMBER,
      psproduc IN NUMBER)
      RETURN NUMBER;   --Traspasa las rentas o recibos pendientes del producto sproduc

   --tipProceso: 0-todos 1- Rentas 2- recibos 3- siniestros

   --Trasferimos los vencimientos de rentas pdtes. a día de hoy
   FUNCTION f_traspasar_venc_renta(pcempres IN NUMBER, pcidioma IN NUMBER, psproduc IN NUMBER)
      RETURN NUMBER;

   -- BUG10604:DRA:02/07/2009:Inici
   /*************************************************************************
    FUNCTION f_act_reembacto
    Actualitza els reembolsos marcant-los com transferits
    param in p_nreemb    : código del reembolso
    return             : NUMBER
   *************************************************************************/
   FUNCTION f_act_reembacto(
      p_nreemb IN NUMBER,
      p_sremesa IN NUMBER,
      p_ftrans IN DATE,
      p_nfact IN NUMBER,   -- BUG10775:APD:25-08-2009
      p_nlinea IN NUMBER,   -- BUG10775:APD:25-08-2009
      p_ctipo IN NUMBER)   -- BUG10775:APD:25-08-2009
      RETURN NUMBER;
-- BUG10604:DRA:02/07/2009:Fi
END pk_transferencias;

/

  GRANT EXECUTE ON "AXIS"."PK_TRANSFERENCIAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_TRANSFERENCIAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_TRANSFERENCIAS" TO "PROGRAMADORESCSI";
