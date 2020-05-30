--------------------------------------------------------
--  DDL for Package PAC_CAJA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CAJA" AUTHID CURRENT_USER IS
   /******************************************************************************
      NOMBRE:     PAC_CAJA
      PROPÓSITO:  Funciones de la Gestión de Caja

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        20/02/2013   XXX                1. Creación del package.
      3.0        16-04-2015   YDA              Se crea la función f_lee_cajamov
      4.0        29/04/2015   YDA              Se crea la función f_delmovcaja_spl
      5.0        29/04/2015   YDA              Se crea la función f_insmovcaja_apply
      6.0        04/05/2015   YDA              Se crea la función f_lee_datmedio_reembolso
      7.0        25/06/2015   MMS              7. 0032660: COLM004-Permitir el pago por caja con tarjeta
    ******************************************************************************/

   -- Bug 0032660/0190245 - 12/11/2014 - JMF
   -- Validar Si el importe supera los ingresos en efectivo realizados en la fecha y moneda de la operación
   FUNCTION f_validaingresoefectivo(pffecmov IN DATE, pcmoneop IN NUMBER, pimovimi IN NUMBER)
      RETURN NUMBER;

   -- Bug 0032660/0190245 - 12/11/2014 - JMF
   -- inserta movimiento y medio (efectivo o actualiza cheques)
   FUNCTION f_confirmadeposito(
      pctipmov IN NUMBER,
      pcusuari IN VARCHAR2,
      pcmoneop IN NUMBER,
      pimovimi IN NUMBER,
      pffecmov IN DATE,
      pnrefdeposito IN NUMBER,
      pcmedmov IN NUMBER,
      pcheques IN t_iax_info)
      RETURN NUMBER;

   -- Bug 0032660/0190245 - 12/11/2014 - JMF
   -- Genera movimiento de saldo inicial
   FUNCTION f_saldoinicial(pfec IN DATE, pmon IN NUMBER, pman IN NUMBER, pcusuari IN VARCHAR2)
      RETURN NUMBER;

   -- Inserta el movimiento en caja
   -- Bug 0032660/0190245 - 12/11/2014 - JMF : pcmanual
   FUNCTION f_insmvtocaja(
      pcempres IN NUMBER,
      pcusuari IN VARCHAR2,
      psperson IN NUMBER,
      pffecmov IN DATE,
      pctipmov IN NUMBER,
      pimovimi IN NUMBER,
      pcmoneop IN NUMBER,
      pseqcaja OUT NUMBER,
      piautliq IN NUMBER DEFAULT NULL,
      pipagsin IN NUMBER DEFAULT NULL,
      piautliqp IN NUMBER DEFAULT NULL,
      pidifcambio IN NUMBER DEFAULT NULL,
      pfcambio IN DATE DEFAULT NULL,
      pcmanual IN NUMBER DEFAULT 1,
      pcusuapunte IN VARCHAR2 DEFAULT NULL,
      ptmotapu IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

   -- Inserta el medio en que se ha efectuado el movimiento de caja
   -- Bug 0032660/0190245 - 12/11/2014 - JMF : pNREFDEPOSITO
   FUNCTION f_inscajadatmedio(
      pseqcaja IN NUMBER,
      pncheque IN VARCHAR2,
      pcestchq IN NUMBER,
      pcbanco IN NUMBER,
      pccc IN VARCHAR2,
      pctiptar IN NUMBER,
      pntarget IN VARCHAR2,
      pfcadtar IN VARCHAR2,
      pimovimi IN NUMBER DEFAULT NULL,
      pcmedmov IN NUMBER DEFAULT NULL,
      pcmoneop IN NUMBER DEFAULT NULL,
      -- Bug 0032660/0190245 - 12/11/2014 - JMF
      pnrefdeposito IN NUMBER DEFAULT NULL,
      pcautoriza IN NUMBER DEFAULT NULL,
      pnultdigtar IN NUMBER DEFAULT NULL,
      pncuotas IN NUMBER DEFAULT NULL,
      pccomercio IN NUMBER DEFAULT NULL,
      --33886/199825  ACL 23/04/2015
      pdsbanco IN VARCHAR2 DEFAULT NULL,
      pctipche IN NUMBER DEFAULT NULL,
      pctipched IN NUMBER DEFAULT NULL,
      pcrazon IN NUMBER DEFAULT NULL,
      pdsmop IN VARCHAR2 DEFAULT NULL,
      pfautori IN DATE DEFAULT NULL,
      pcestado IN NUMBER DEFAULT NULL,
      psseguro IN NUMBER DEFAULT NULL,
      psseguro_d IN NUMBER DEFAULT NULL,
      pseqcaja_o IN NUMBER DEFAULT NULL,
      ptdescchk IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
       Obtiene los movimientos asociados a un usuario/fecha
       param in pcusuari  : Codigo del Usuario
       param in pffecmov  : Fecha de los movimientos
       param out mensajes : mensajes de error
       return             : 0 si todo ha ido bien o 1
    *************************************************************************/
   FUNCTION f_obtenermvtocaja(
      pcusuari cajamov.cusuari%TYPE,
      pffecmov_ini cajamov.ffecmov%TYPE,
      pffecmov_fin cajamov.ffecmov%TYPE,
      pctipmov cajamov.ctipmov%TYPE,
      pcmedmov caja_datmedio.cmedmov%TYPE,
      pcidioma IN NUMBER,
      ptselect OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
       Función que inserta totalizado los importes del pago carga masiva


       return             : 0 si todo ha ido bien o 1
    *************************************************************************/
   FUNCTION f_ins_pagos_masivo(psproces IN NUMBER, pfcarga IN DATE, ptfichero IN VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
        Función que actualiza que se ha pagado un fichero masivo cargado


       return             : 0 si todo ha ido bien o 1
    *************************************************************************/
   FUNCTION f_upd_pagos_masivo(
      psproces IN NUMBER,
      pseqcaja IN NUMBER,
      piautoliq IN NUMBER DEFAULT NULL,
      piautoliqp IN NUMBER DEFAULT NULL,
      pidifcambio IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
       Función que obtiene los ficheros de carga de pagos masivos


       return             : 0 si todo ha ido bien o 1
    *************************************************************************/
   FUNCTION f_lee_pagos_mas_pdtes(pcagente IN agentes.cagente%TYPE, pmoneprod IN NUMBER)
      RETURN sys_refcursor;

    /******************************************************************************
     NOMBRE:     f_ins_det_autliq
     PROPÓSITO:  Función que inserta el detalle de las autiliquidaciones tomadas
     en las cargas de pago masiva
     PARAMETROS:
          return            : 0 -> Todo correcto
                              1 -> Se ha producido un error
   *****************************************************************************/
   FUNCTION f_ins_det_autliq(
      pcagente IN NUMBER,
      psproces IN NUMBER,
      pcmonope IN NUMBER,
      psproduc IN NUMBER,
      piautliq IN NUMBER)
      RETURN NUMBER;

    /******************************************************************************
     NOMBRE:     f_ins_sobrante
     PROPÓSITO:  Función que inserta el sobrante de los pagos masivos
     PARAMETROS:
          return            : 0 -> Todo correcto
                              1 -> Se ha producido un error
   *****************************************************************************/
   FUNCTION f_lee_pagos_pdtes(pcagente IN agentes.cagente%TYPE)
      RETURN sys_refcursor;

   FUNCTION f_lee_sobrante(pcagente IN NUMBER, ptfichero IN VARCHAR2, ptselect OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_ins_sobrante(pspagmas IN NUMBER, pimporte IN NUMBER, pcmovimi IN NUMBER)
      RETURN NUMBER;

    --BUG 32667:NSS:13/10/2014
   /******************************************************************************
     NOMBRE:     f_anula_aportini
     PROPÓSITO:  Función que dada la solicitud rechazada nos generará un apunte de devolución del pago inicial,
                 si existe algún pago inicial para este cliente/producto.
     PARAMETROS: sseguro
                 sproduc
          return            : 0 -> Todo correcto
                              1 -> Se ha producido un error
   *****************************************************************************/
   FUNCTION f_anula_aportini(psseguro IN NUMBER, psproduc IN NUMBER)
      RETURN NUMBER;

   --INI BUG 32661:NSS:03/11/2014
   /*************************************************************************
      Valida valor ingresado
      param in nrefdeposito        : numero de deposito
      param in iimpins        : importe
      param in out mensajes : mesajes de error
      return                : descripción del valor
   *************************************************************************/
   FUNCTION f_valida_valor_ingresado(
      pnrefdeposito IN NUMBER,
      pimovimi IN NUMBER,
      pcmoneop IN VARCHAR2,
      pcidioma IN NUMBER,
      pconfirm OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
      Obtiene "cheques" y "vales vista" entrados por caja por el propio usuario, con estado "Aceptado", en la moneda seleccionada por
      pantalla y que no estén vinculados con ninguna referencia de depósito anterior, permitiendo su selección para ser incluidos en
      la referencia de depósito
      param in nrefdeposito        : numero de deposito
      param in iimpins        : importe
      param in out mensajes : mesajes de error
      return                : descripción del valor
   *************************************************************************/
   FUNCTION f_get_cheques(
      pnrefdeposito IN NUMBER,
      pimovimi IN NUMBER,
      pcmoneop IN VARCHAR2,
      pcidioma IN NUMBER,
      ptselect OUT VARCHAR2)
      RETURN NUMBER;

--FIN BUG 32661:NSS:03/11/2014

   -- Bug 0032660/0190245 - 12/11/2014 - JMF
   -- Calcular el codigo comercio asociado al agente que tiene definido el usuario
   FUNCTION f_comercio_usuario(pcusuari IN VARCHAR2)
      RETURN NUMBER;

--Bug 33886/199825 ACL
     /******************************************************************************
      NOMBRE:     F_UPDATE_CAJA
      PROPÓSITO:  Funcion que realiza un update de los campos CAJA_DATMEDIO.CESTCHE
                  y CAJA_DATMEDIO.FAUTORI.
    *************************************************************************/
   FUNCTION f_update_caja(pseqcaja IN NUMBER)
      RETURN NUMBER;

   -- Función que obtiene los movimientos de caja y sus detalles - YDA
   FUNCTION f_lee_cajamov(
      psseguro IN seguros.sseguro%TYPE,
      pseqcaja IN cajamov.seqcaja%TYPE,
      pstatus IN NUMBER)
      RETURN sys_refcursor;

   -- Bug 33886/202377 - 04/05/2015
   -- Función que devuelve datos de datmedio para la pantalla de reembolso
   FUNCTION f_lee_datmedio_reembolso(
      psseguro IN caja_datmedio.sseguro%TYPE,
      psperson IN cajamov.sperson%TYPE,
      pcestado IN caja_datmedio.cestado%TYPE)
      RETURN sys_refcursor;

   FUNCTION f_insmovcaja_spl(
      pcempres NUMBER,
      psseguro NUMBER,
      pimporte NUMBER,
      --v_seqcaja,   --pseqcaja IN NUMBER,
      pncheque IN VARCHAR2 DEFAULT NULL,
      --el número de cheque puede venir de parametro
      pcestchq IN NUMBER DEFAULT NULL,   --el estado del cheque
      pcbanco IN NUMBER DEFAULT NULL,
--si el pago fue porque el cliente acreditó a una cuenta bancaria, el codigo del banco
      pccc IN VARCHAR2 DEFAULT NULL,   --el número de cuenta
      pctiptar IN NUMBER DEFAULT NULL,
      --si fuera por tarjeta de credito el tipo de la tarjeta
      pntarget IN NUMBER DEFAULT NULL,
      --el número de la tarjeta de crédito
      pfcadtar IN VARCHAR2 DEFAULT NULL,
                                        --cuando caduca la tarjeta de crédito
      --100,   --pimovimi IN NUMBER,     --el importe del movimiento
      pcmedmov IN NUMBER DEFAULT NULL,   -->detvalores 841
      pcmoneop IN NUMBER DEFAULT 1,
--> 1 EUROS  moneda en que se realiza la operación, debo convertir de esa moneda a la moneda del producto para ver si puedo pagar el recibo
      pnrefdeposito IN NUMBER DEFAULT NULL,   -->referencia del depósito
      pcautoriza IN NUMBER DEFAULT NULL,
      -->codigo de autorización si fuera tarjeta de crédito
      pnultdigtar IN NUMBER DEFAULT NULL,
      -->cuatro últimos dígitos de la tarjeta de crédito
      pncuotas IN NUMBER DEFAULT NULL,   -->no aplica para msv
      pccomercio IN NUMBER DEFAULT NULL,
      --BUG 33886/199827 -JCP
      pcestado IN NUMBER DEFAULT 3,
      psseguro_d IN NUMBER DEFAULT NULL,
      pcrazon IN NUMBER DEFAULT NULL,
      pseqcaja_o NUMBER DEFAULT NULL,
      PSPERSON IN NUMBER DEFAULT NULL,
      p_valida_saldo IN NUMBER DEFAULT 1)
      RETURN NUMBER;

   --Obtiene la suma de recibos de caja de reembolsos msv - JCP
   FUNCTION f_get_suma_caja(
      psseguro IN seguros.sseguro%TYPE,
      psperson IN per_detper.sperson%TYPE,
      pcestado IN NUMBER)
      RETURN NUMBER;

   -- Función que borra de caja_detmedio
   FUNCTION f_delmovcaja_spl(
      psseguro IN caja_datmedio.sseguro%TYPE,
      pseqcaja IN caja_datmedio.seqcaja%TYPE,
      pnnumlin IN caja_datmedio.nnumlin%TYPE,
      pcestado IN caja_datmedio.cestado%TYPE)
      RETURN NUMBER;

   -- Función que cambia el estado de las transacciones de una caja
   FUNCTION f_insmovcaja_apply(
      psseguro IN caja_datmedio.sseguro%TYPE,
      psperson IN cajamov.sperson%TYPE)
      RETURN NUMBER;

   FUNCTION f_aprueba_caja_spl(
      psseguro IN caja_datmedio.sseguro%TYPE,
      psperson IN cajamov.sperson%TYPE,
      pseqcaja IN cajamov.seqcaja%TYPE,
      pautoriza IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
     funcion que inserta en pago cliente
     param psseguro: codigo del seguro
     param psperson : codigo de persona
     return : resultado del proceso
     Bug 33886/205948 mnustes
   *************************************************************************/
   FUNCTION f_ins_pagoctacliente(
      psseguro IN seguros.sseguro%TYPE,
      psperson IN per_personas.sperson%TYPE,
      piimporte IN pagoctacliente.iimporte%TYPE,
      pnnumlin IN pagoctacliente.nnumlin%TYPE)
      RETURN NUMBER;
END pac_caja;

/

  GRANT EXECUTE ON "AXIS"."PAC_CAJA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CAJA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CAJA" TO "PROGRAMADORESCSI";
