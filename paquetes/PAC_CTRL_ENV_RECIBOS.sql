--------------------------------------------------------
--  DDL for Package PAC_CTRL_ENV_RECIBOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CTRL_ENV_RECIBOS" IS
/******************************************************************************
   NOMBRE:      PAC_CARGAS_ENSA
   PROPÓSITO: Funciones para la gestión de la carga de procesos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        06/11/2011   JRH              1. Creación del package.
   2.0        05/03/2013   AMJ              2. 0026265: LCOL_T001-QT 6336: Retenida por env?o fallido a la ERP
   3.0        04/12/2017   ABC              3. CONF-403:Creacion nueva funcion f_procesar_reccaus comision causacion.
******************************************************************************/

   -- Bug 19290- JRH - 06/09/2011 - 0019290: ENSA102- Tabla de control de los recibos que se envían a SAP
/*************************************************************************
      procedimiento que inserta un movimiento de recibo a tratar
      param in psproces   : Proceso
      param in pcempres :  Empresa
      param in pctipopago   : Tipo pago/recibo (1,2,3,4)
      param in   pnpago   : Pago/Recibo
      param in   pnmov   : Número de movmimento del pago /recibo
      param in pctipomov: Por facilidad indicar si 1  es emisión o 2 anulación
      retorna 0 si ha ido bien, 1 en casos contrario
   *************************************************************************/
   FUNCTION f_ins_recproc(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pctipopago IN NUMBER,
      pnpago IN NUMBER,
      pnmov IN NUMBER,
      pctipomov IN NUMBER DEFAULT 1,
      psseguro IN NUMBER DEFAULT NULL)   --BUG: 26265  05/03/2013 AMJ
      RETURN NUMBER;

/*************************************************************************
      Función que actualiza el estado de un movimiento de recibo a tratar
       param in pctipopago   : Tipo pago/recibo (1,2,3,4)
       param in   pnpago   : Pago/Recibo
           param in   pnmov   : Número de movmimento del pago /recibo
            param in   cestado   : Estado del movimiento
                param in   terror   : Texto de error
       retorna 0 si ha ido bien, 1 en casos contrario

   *************************************************************************/
   FUNCTION f_act_estado(
      pctipopago IN NUMBER,
      pnpago IN NUMBER,
      pnmov IN NUMBER,
      pcestado IN NUMBER,
      pterror IN VARCHAR2,
      psinterf IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
        Función que actualiza el estado de un movimiento de recibo a tratar
        param in psproces   : Proceso
        param in pctipopago   : Tipo pago/recibo (1,2,3,4)
        param in   pnpago   : Pago/Recibo
        param in   pnmov   : Número de movmimento del pago /recibo

        retorna 0 si ha ido bien, 1 en casos contrario

   *************************************************************************/
   FUNCTION f_procesar_pendientes_proc(
      psproces IN NUMBER,
      pnok OUT NUMBER,
      pnko OUT NUMBER,
      pctipopago IN NUMBER DEFAULT NULL,
      pnpago IN NUMBER DEFAULT NULL,
      pnmov IN NUMBER DEFAULT NULL,
      psseguro IN NUMBER DEFAULT NULL)   --BUG:26265   05/03/2013  AMJ
      RETURN NUMBER;

        /*************************************************************************
       Función que procesa un pago
       param in pcempres: Empresa
       param in pctipopago   : Tipo pago/recibo (1,2,3,4)
       param in   pnpago   : Pago/Recibo
       param in   pnmov   : Número de movmimento del pago /recibo

       retorna 0 si ha ido bien, 1 en casos contrario

   *************************************************************************/
   FUNCTION f_procesar_recpago(
      pcempres IN NUMBER,
      pctipopago IN NUMBER,
      pnpago IN NUMBER,
      pnmov IN NUMBER,
      ptipoaccion IN NUMBER,
      psproces IN NUMBER,
      pterror OUT VARCHAR2,
      psinterf OUT NUMBER)
      RETURN NUMBER;
   /*************************************************************************
       Función que procesa la contabilidad de causacion de comision
       param in pcempres: Empresa
       param in pctipopago   : Tipo pago/recibo (1,2,3,4)
       param in   pnpago   : Pago/Recibo
       param in   pnmov   : Número de movmimento del pago /recibo
       Version 3.0
       retorna 0 si ha ido bien, 1 en casos contrario

   *************************************************************************/
   FUNCTION f_procesar_reccaus(
      pcempres IN NUMBER,
      pctipopago IN NUMBER,
      pnpago IN NUMBER,
      pnmov IN NUMBER,
      ptipoaccion IN NUMBER,
      psproces IN NUMBER,
      pterror OUT VARCHAR2,
      psinterf OUT NUMBER,
      precaudo IN NUMBER DEFAULT 0)
      RETURN NUMBER;
   /*************************************************************************
      Función que actualiza el estado de un movimiento de recibo a tratar en AXIS
      param in pctipopago   : Tipo pago/recibo (1 pago,2 renta prestaren ,3 renta seguros_ren,4 recibo)
      param in   pnpago   : Pago/Recibo
      param in   pnmov   : Número de movmimento del pago /recibo
      param in   cestado   : Estado del movimiento
      param in   ptipoaccion   : 1 emisión , 2 anulación
      param in   psproces   : procesos
      retorna 0 si ha ido bien, 1 en casos contrario

   *************************************************************************/
   FUNCTION f_act_estado_pagofin(
      pctipopago IN NUMBER,
      pnpago IN NUMBER,
      pnmov IN NUMBER,
      ptipoaccion IN NUMBER,
      psproces IN NUMBER)
      RETURN NUMBER;

/*************************************************************************
      Función que procesa lors recibos de un movimiento de póliza
      param in pcempers : Empresa
      param in psseguro : Sseguro
      param in Pnmovimi : Pnmovimi
      param in pctipopago   : Tipo pago/recibo (1 pago,2 renta prestaren ,3 renta seguros_ren,4 recibo)
      param in out psproces : Número de proceso
      param in penvaport number : indica si se ha de enviar la aportacion extraordinaria a SAP
      retorna 0 si ha ido bien, error en caso contrario

   *************************************************************************/
   FUNCTION f_proc_recpag_mov(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pctipopago IN NUMBER,
      psproces IN NUMBER,
      penvaport IN NUMBER DEFAULT 0)
      RETURN NUMBER;

/*************************************************************************
      Función que procesa lors recibos de un movimiento de póliza
      param in pcempers : Empresa
      param in psseguro : Sseguro
      param in Pnmovimi : Pnmovimi
      param in pctipopago   : Tipo pago/recibo (1 pago,2 renta prestaren ,3 renta seguros_ren,4 recibo)
      param in out psproces : Número de proceso
      param in penvaport number : indica si se ha de enviar la aportacion extraordinaria a SAP
      retorna 0 si ha ido bien, error en caso contrario

   *************************************************************************/
   FUNCTION f_proc_recpag_mov_clon(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pctipopago IN NUMBER,
      psproces IN NUMBER,
      penvaport IN NUMBER DEFAULT 0)
      RETURN NUMBER;
END pac_ctrl_env_recibos;

/

  GRANT EXECUTE ON "AXIS"."PAC_CTRL_ENV_RECIBOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CTRL_ENV_RECIBOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CTRL_ENV_RECIBOS" TO "PROGRAMADORESCSI";
