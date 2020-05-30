--------------------------------------------------------
--  DDL for Package PAC_CONTROL_REEMBOLSO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CONTROL_REEMBOLSO" AUTHID CURRENT_USER IS
   /******************************************************************************
      NOMBRE:    PAC_CONTROL_REEMBOLSO
      PROPOSITO: Funcion que valida todos los reembolsos de la compa?ia. Todos los registros
                 que se inserten en la tabla reemb_actos han de pasar por este funcion para
                 su validacion y mientras el codigo de error no sea cero el registro no podra
                 ser aceptado y transferido
      REVISIONES:
      Ver        Fecha        Autor             Descripcion
      ---------  ----------  ---------------  ------------------------------------
      1.0        18/08/2008   XVILA             1. Creacion del package.
      2.0        01/07/2009   DRA               2. 0010604: Nuevo control Reembolsos - Pago Retenido
      3.0        27/07/2009   DRA               3. 0010761: CRE - Reembolsos
      4.0        25/08/2009   DRA               4. 0010949: CRE - Pruebas modulo reembolsos
      5.0        06/10/2009   DRA               5. 0011190: CRE- Modificaciones en modulo de reembolsos.
      6.0        15/03/2010   DRA               6. 0012676: CRE201 - Consulta de reembolsos - Ocultar descripcion de Acto y otras mejoras
      7.0        26/03/2010   DRA               7. 0013927: CRE049 - Control cambio de estado reembolso
      8.0        18/01/2011   DRA               8. 0016576: AGA602 - Parametrització de reemborsaments per veterinaris
   ******************************************************************************/
   FUNCTION f_validareemb(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      psmancont NUMBER DEFAULT NULL,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER;

   FUNCTION f_control_rmb01(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER;

   FUNCTION f_control_rmb02(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER;

   FUNCTION f_control_rmb03(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER;

   FUNCTION f_control_rmb04(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER;

   FUNCTION f_control_rmb05(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER;

   FUNCTION f_control_rmb06(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER;

   FUNCTION f_control_rmb07(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER;

   FUNCTION f_control_rmb08(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER;

   FUNCTION f_control_rmb09(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER;

   FUNCTION f_control_rmb10(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER;

   FUNCTION f_control_rmb11(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER;

   FUNCTION f_control_rmb12(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER;

   FUNCTION f_control_rmb13(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER;

   FUNCTION f_control_rmb14(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER;

   FUNCTION f_control_rmb15(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER;

   FUNCTION f_control_rmb16(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER;

   FUNCTION f_control_rmb17(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER;

   FUNCTION f_control_rmb18(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER;

   FUNCTION f_control_rmb19(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER;

   FUNCTION f_control_rmb20(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER;

   FUNCTION f_control_rmb21(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER;

   FUNCTION f_control_rmb22(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER;

   FUNCTION f_control_rmb23(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER;

   FUNCTION f_control_rmb24(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER;

   -- BUG10949:DRA:25/08/2009:Inici
   /*************************************************************************
       FUNCTION f_control_rmb25
    Valida si se informa el pago complemento pero no existe factura complementaria
        param in ptipo       : tipo
        param in psseguro    : codigo del seguro
        param in pnriesgo    : codigo del riesgo
        param in pcgarant    : codigo de la garantia
        param in psperson    : codigo de la persona
        param in pagr_salud  : codigo de la agrupacion
        param in pcacto      : codigo del acto
        param in pnacto      : numero de acto
        param in pfacto      : fecha del acto
        param in piimporte   : importe
        param in pnreemb     : numero de reembolso
        param in pnfact      : numero de factura
        param in pnlinea     : numero de linea
        param in pnfact_cli  : numbero de factura de cliente
        param in pftrans     : fecha de transferencia
        return               : NUMBER
   *************************************************************************/
   FUNCTION f_control_rmb25(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER;

   /*************************************************************************
                                                    FUNCTION f_control_rmb26
    Valida si se informa el pago complemento en un reembolso de la agrupacion 2
        param in ptipo       : tipo
        param in psseguro    : codigo del seguro
        param in pnriesgo    : codigo del riesgo
        param in pcgarant    : codigo de la garantia
        param in psperson    : codigo de la persona
        param in pagr_salud  : codigo de la agrupacion
        param in pcacto      : codigo del acto
        param in pnacto      : numero de acto
        param in pfacto      : fecha del acto
        param in piimporte   : importe
        param in pnreemb     : numero de reembolso
        param in pnfact      : numero de factura
        param in pnlinea     : numero de linea
        param in pnfact_cli  : numbero de factura de cliente
        param in pftrans     : fecha de transferencia
        return               : NUMBER
   *************************************************************************/
   FUNCTION f_control_rmb26(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER;

   -- BUG10949:DRA:25/08/2009:Fi

   -- BUG11190:DRA:06/10/2009:Inici
   /*************************************************************************
       FUNCTION f_control_rmb27
    La suma total de los importes (ipago + ipagocomp + icass) de todos los
     registros de actos en un reembolso han de inferior o igual a la suma
     del importe de las factura complementarias del reembolso.
        param in ptipo       : tipo
        param in psseguro    : codigo del seguro
        param in pnriesgo    : codigo del riesgo
        param in pcgarant    : codigo de la garantia
        param in psperson    : codigo de la persona
        param in pagr_salud  : codigo de la agrupacion
        param in pcacto      : codigo del acto
        param in pnacto      : numero de acto
        param in pfacto      : fecha del acto
        param in piimporte   : importe
        param in pnreemb     : numero de reembolso
        param in pnfact      : numero de factura
        param in pnlinea     : numero de linea
        param in pnfact_cli  : numbero de factura de cliente
        param in pftrans     : fecha de transferencia
        return               : NUMBER
   *************************************************************************/
   FUNCTION f_control_rmb27(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER;

   -- BUG11190:DRA:06/10/2009:Fi

   -- BUG15179:SMF:22/10/2010:Inici
   /*************************************************************************
       FUNCTION f_control_rmb28
    Se controla que el producto de autonomos no pague m?s de 750 euros por todos los
    actos relacionados con el dentista en un a?o. Autonomos es agr_salud =6
        param in ptipo       : tipo
        param in psseguro    : codigo del seguro
        param in pnriesgo    : codigo del riesgo
        param in pcgarant    : codigo de la garantia
        param in psperson    : codigo de la persona
        param in pagr_salud  : codigo de la agrupacion
        param in pcacto      : codigo del acto
        param in pnacto      : numero de acto
        param in pfacto      : fecha del acto
        param in piimporte   : importe
        param in pnreemb     : numero de reembolso
        param in pnfact      : numero de factura
        param in pnlinea     : numero de linea
        param in pnfact_cli  : numbero de factura de cliente
        param in pftrans     : fecha de transferencia
        return               : NUMBER
   *************************************************************************/
   FUNCTION f_control_rmb28(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG15179:SMF:22/10/2010
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_control_rmb29
      Se controla que durante el primer y segundo a?o , y si es agr_salud = 4 ,
      el gasto de ortodoncia no supere loes 470 euros, y 706 en los sucesivos.
          param in ptipo       : tipo
          param in psseguro    : codigo del seguro
          param in pnriesgo    : codigo del riesgo
          param in pcgarant    : codigo de la garantia
          param in psperson    : codigo de la persona
          param in pagr_salud  : codigo de la agrupacion
          param in pcacto      : codigo del acto
          param in pnacto      : numero de acto
          param in pfacto      : fecha del acto
          param in piimporte   : importe
          param in pnreemb     : numero de reembolso
          param in pnfact      : numero de factura
          param in pnlinea     : numero de linea
          param in pnfact_cli  : numbero de factura de cliente
          param in pftrans     : fecha de transferencia
          return               : NUMBER
     *************************************************************************/
   FUNCTION f_control_rmb29(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG15179:SMF:22/10/2010
      RETURN NUMBER;

   -- BUG16576:DRA:18/01/2011:Inici
   /*************************************************************************
      FUNCTION f_control_rmb30
      Se controla que sólo haya 1 acto cada 5 años.
          param in ptipo       : tipo
          param in psseguro    : codigo del seguro
          param in pnriesgo    : codigo del riesgo
          param in pcgarant    : codigo de la garantia
          param in psperson    : codigo de la persona
          param in pagr_salud  : codigo de la agrupacion
          param in pcacto      : codigo del acto
          param in pnacto      : numero de acto
          param in pfacto      : fecha del acto
          param in piimporte   : importe
          param in pnreemb     : numero de reembolso
          param in pnfact      : numero de factura
          param in pnlinea     : numero de linea
          param in pnfact_cli  : numbero de factura de cliente
          param in pftrans     : fecha de transferencia
          return               : NUMBER
     *************************************************************************/
   FUNCTION f_control_rmb30(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG15179:SMF:22/10/2010
      RETURN NUMBER;

   -- BUG16576:DRA:18/01/2011:Fi

   -- BUG10604:DRA:01/07/2009:Inici
   /*************************************************************************
       FUNCTION f_control_rmb100
    Valida si es de origen manual o automatico
        param in ptipo       : tipo
        param in psseguro    : codigo del seguro
        param in pnriesgo    : codigo del riesgo
        param in pcgarant    : codigo de la garantia
        param in psperson    : codigo de la persona
        param in pagr_salud  : codigo de la agrupacion
        param in pcacto      : codigo del acto
        param in pnacto      : numero de acto
        param in pfacto      : fecha del acto
        param in piimporte   : importe
        param in pnreemb     : numero de reembolso
        param in pnfact      : numero de factura
        param in pnlinea     : numero de linea
        param in pnfact_cli  : numbero de factura de cliente
        param in pftrans     : fecha de transferencia
        return               : NUMBER
   *************************************************************************/
   FUNCTION f_control_rmb100(
      ptipo NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      psperson NUMBER,
      pagr_salud VARCHAR2,
      pcacto VARCHAR2,
      pnacto NUMBER,
      pfacto DATE,
      piimporte NUMBER,
      pnreemb NUMBER,
      pnfact NUMBER,
      pnlinea NUMBER,
      pnfact_cli VARCHAR2,
      pftrans DATE)   -- BUG10761:DRA:27/07/2009
      RETURN NUMBER;
-- BUG10604:DRA:01/07/2009:Fi
END pac_control_reembolso;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_CONTROL_REEMBOLSO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CONTROL_REEMBOLSO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CONTROL_REEMBOLSO" TO "PROGRAMADORESCSI";
