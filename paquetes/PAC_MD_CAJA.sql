--------------------------------------------------------
--  DDL for Package PAC_MD_CAJA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_CAJA" AS
   /******************************************************************************
      NOMBRE:       PAC_MD_CAJA
      PROPÓSITO:  Funciones que gestionan el módulo de CAJA

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        25/02/2013   AFM                1. Creación del package.
      2.0        26/02/2015   JAMF               2. 5. 0034022: RSA300 - Proceso pagos masivo no finaliza (Ejecutarlo como job)
      2.0        10-10-2013   JMF              0028517: RSA998 - CAJA. Pago de recibos requiere recaudación
      3.0        16/04/2015   YDA                3. Se crea la función f_lee_cajamov
      4.0        29/04/2015   YDA                4. Se crea de la función f_delmovcaja_spl
      5.0        30/04/2015   YDA                5. Se crea la función f_insmovcaja_apply
      6.0        04/05/2015   YDA                6. Se crea la función f_lee_datmedio_reembolso
   ******************************************************************************/

   /*************************************************************************
      Obtiene los ficheros pendientes de pagar por el partner
      param in sperson  : Codigo de agente
      param out mensajes : mensajes de error
      return             : 0 si todo ha ido bien o 1
   *************************************************************************/
   FUNCTION f_lee_pagos_mas_pdtes(
      pcagente agentes.cagente%TYPE,
      pcmoneda monedas.cmonint%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Función que actualiza que se ha pagado el fichero masivo cargado


      return             : 0 si todo ha ido bien o 1
   *************************************************************************/
   FUNCTION f_upd_pagos_masivo(
      pcadena IN VARCHAR2,
      pcadforpag IN VARCHAR2,
      pcempres IN NUMBER,
      pcusuari IN VARCHAR2,
      psperson IN NUMBER,
      pctipmov IN NUMBER,
      pimovimi IN NUMBER,
      piautliq IN NUMBER,
      pipagsin IN NUMBER,
      pcmoneop IN NUMBER,
      piautliqp IN NUMBER DEFAULT NULL,
      pidifcambio IN NUMBER DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Función que actualiza que se ha pagado el fichero masivo cargado
      Ejecución mediante job

      return             : 0 si todo ha ido bien o 1
   *************************************************************************/
   FUNCTION f_ejecuta_upd_pagos_masivo(
      pcadena IN VARCHAR2,
      pcadforpag IN VARCHAR2,
      pcempres IN NUMBER,
      pcusuari IN VARCHAR2,
      psperson IN NUMBER,
      pctipmov IN NUMBER,
      pimovimi IN NUMBER,
      piautliq IN NUMBER,
      pipagsin IN NUMBER,
      pcmoneop IN NUMBER,
      piautliqp IN NUMBER DEFAULT NULL,
      pidifcambio IN NUMBER DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
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
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- Bug 0032660/0190245 - 12/11/2014 - JMF : pcmanual
   FUNCTION f_ins_movtocaja(
      pcempres IN NUMBER,
      pcusuari IN VARCHAR2,
      psperson IN NUMBER,
      pffecmov IN DATE,
      pctipmov IN NUMBER,
      pimovimi IN NUMBER,
      piautliq IN NUMBER,
      pipagsin IN NUMBER,
      pcmoneop IN NUMBER,
      pcmedmov IN NUMBER,
      pncheque IN VARCHAR2,
      pcestchq IN NUMBER,
      pcbanco IN NUMBER,
      pccc IN VARCHAR2,
      pctiptar IN NUMBER,
      pntarget IN NUMBER,
      pfcadtar IN VARCHAR2,
      pseqcaja OUT NUMBER,
      mensajes OUT t_iax_mensajes,
      pidifcambio IN NUMBER DEFAULT NULL,
      pfcambio IN DATE DEFAULT NULL,
      pcmanual IN NUMBER DEFAULT 1,
      -- Bug 0032660/0190245 - 12/11/2014 - JMF
      pcautoriza IN NUMBER DEFAULT NULL,
      pnultdigtar IN NUMBER DEFAULT NULL,
      pncuotas IN NUMBER DEFAULT NULL,
      pccomercio IN NUMBER DEFAULT NULL,
      --BUG 33886/199827
      pcestado IN NUMBER DEFAULT NULL,
      psseguro IN VARCHAR2 DEFAULT NULL,
      psseguro_d IN VARCHAR2 DEFAULT NULL,
      pcrazon IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_get_agente(pcagente IN NUMBER, mensajes IN OUT t_iax_mensajes)
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
      piautliq IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_ins_movto_pinicial(
      pcempres IN NUMBER,
      pcusuari IN VARCHAR2,
      psperson IN NUMBER,
      pffecmov IN DATE,
      pctipmov IN NUMBER,
      pimovimi IN NUMBER,
      psproduc IN NUMBER,
      pcmoneop IN NUMBER,
      pcmedmov IN NUMBER,
      pncheque IN VARCHAR2,
      pcestchq IN NUMBER,
      pcbanco IN NUMBER,
      pccc IN VARCHAR2,
      pctiptar IN NUMBER,
      pntarget IN NUMBER,
      pfcadtar IN VARCHAR2,
      pseqcaja OUT NUMBER,
      mensajes OUT t_iax_mensajes,
      pfcambio IN DATE,   --Bug.: 32665 - casanchez - 03/09/2014 - Se añade el nuevo parametro de fecha de pago
      -- Bug 0032660/0190245 - 12/11/2014 - JMF
      pcautoriza IN NUMBER DEFAULT NULL,
      pnultdigtar IN NUMBER DEFAULT NULL,
      pncuotas IN NUMBER DEFAULT NULL,
      pccomercio IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_lee_pagos_pdtes(pcagente agentes.cagente%TYPE, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_lee_sobrante(
      pcagente IN NUMBER,
      ptfichero IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_ins_sobrante(pspagmas IN NUMBER, pimporte IN NUMBER, pcmovimi IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_ins_devolucion(pcadena IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Bug 0032660/0190245 - 12/11/2014 - JMF
   FUNCTION f_apuntemanual(
      pctipmov IN NUMBER,
      pcusuari1 IN VARCHAR2,
      pcusuari2 IN VARCHAR2,
      pcmoneop IN VARCHAR2,
      pimovimi IN NUMBER,
      pffecmov IN DATE,
      ptmotapu IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   --INI BUG 32661:NSS:03/11/2014
   /*************************************************************************
      Valida valor ingresado
      param in nrefdeposito        : numero de deposito
      param in pimovimi        : importe
      param in out mensajes : mesajes de error
      return                : descripción del valor
   *************************************************************************/
   FUNCTION f_valida_valor_ingresado(
      pnrefdeposito IN NUMBER,
      pimovimi IN NUMBER,
      pcmoneop IN VARCHAR2,
      pconfirm OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
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
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_confirmadeposito(
      pcmoneop IN NUMBER,
      pimovimi IN NUMBER,
      pnrefdeposito IN NUMBER,
      pcmedmov IN NUMBER,
      pcheques IN t_iax_info,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

--FIN BUG 32661:NSS:03/11/2014

   -- Bug 0032660/0190245 - 12/11/2014 - JMF
   /*************************************************************************
      Obtener comercio del agente asignado al usuario
      param in pcusuari     : usuario
      param out pcomercio   : comercio
      param in out mensajes : mesajes de error
      return                : descripción del valor
   *************************************************************************/
   FUNCTION f_comercio_usuario(
      pcusuari IN VARCHAR2,
      pcomercio OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

        -- Bug 33886/199825 ACL
   /******************************************************************************
        NOMBRE:     F_UPDATE_CAJA
        PROPÓSITO:  Funcion que realiza un update de los campos CAJA_DATMEDIO.CESTCHE
                    y CAJA_DATMEDIO.FAUTORI.
        param in out mensajes : mesajes de error
        return                : descripción del valor
      *****************************************************************************/
   FUNCTION f_update_caja(pseqcaja IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Bug 33886/202377 - 16/04/2015
   -- Función que obtiene los movimientos de caja y sus detalles
   FUNCTION f_lee_cajamov(
      psseguro IN seguros.sseguro%TYPE,
      pseqcaja IN cajamov.seqcaja%TYPE,
      pstatus IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- Bug 33886/202377 - 04/05/2015
   -- Función que devuelve datos de datmedio para la pantalla de reembolso
   FUNCTION f_lee_datmedio_reembolso(
      psseguro IN caja_datmedio.sseguro%TYPE,
      psperson IN cajamov.sperson%TYPE,
      pcestado IN caja_datmedio.cestado%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   --JCP
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
      pnrefdeposito IN NUMBER DEFAULT NULL,
      -->referencia del depósito
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
      psperson IN NUMBER DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   --Obtiene la suma de recibos de caja de reembolsos msv - JCP
   FUNCTION f_get_suma_caja(
      psseguro IN seguros.sseguro%TYPE,
      psperson IN per_detper.sperson%TYPE,
      pcestado IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Función que borra de caja_detmedio
   FUNCTION f_delmovcaja_spl(
      psseguro IN caja_datmedio.sseguro%TYPE,
      pseqcaja IN caja_datmedio.seqcaja%TYPE,
      pnnumlin IN caja_datmedio.nnumlin%TYPE,
      pcestado IN caja_datmedio.cestado%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Función que cambia el estado de las transacciones de una caja
   FUNCTION f_insmovcaja_apply(
      psseguro IN caja_datmedio.sseguro%TYPE,
      psperson IN cajamov.sperson%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_aprueba_caja_spl(
      psseguro IN caja_datmedio.sseguro%TYPE,
      psperson IN cajamov.sperson%TYPE,
      pseqcaja IN cajamov.seqcaja%TYPE,
      pautoriza IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_caja;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_CAJA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CAJA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CAJA" TO "PROGRAMADORESCSI";
