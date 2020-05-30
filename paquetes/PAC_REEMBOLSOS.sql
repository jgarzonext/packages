--------------------------------------------------------
--  DDL for Package PAC_REEMBOLSOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_REEMBOLSOS" IS
/******************************************************************************
   NOMBRE:     pac_reembolso
   PROPÓSITO:  Contiene funciones y procedimientos para operar con reembolsos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        ??/??/????   ???              1. Creación del objeto.
   2.0        03/07/2009   DRA              2. 0010631: CRE - Modificaciónes modulo de reembolsos
   3.0        04/07/2009   DRA              3. 0010704: CRE - Traspaso de facturas para reembolso con mismo Nº Hoja CASS
   4.0        02/10/2009   XVM              4. 0011285: CRE - Transferencias de reembolsos
   5.0        22/02/2011   DRA              5. 0017732: CRE998 - Modificacions mòdul reemborsaments
******************************************************************************/
   FUNCTION ff_contador_reembolsos(psseguro IN seguros.sseguro%TYPE, pnreemb OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_ins_reembolso(
      pnreemb IN OUT reembolsos.nreemb%TYPE,
      psseguro IN reembolsos.sseguro%TYPE,
      pnriesgo IN reembolsos.nriesgo%TYPE,
      pcgarant IN reembolsos.cgarant%TYPE,
      pcestado IN reembolsos.cestado%TYPE,
      pfestado IN reembolsos.festado%TYPE,
      ptobserv IN reembolsos.tobserv%TYPE,
      pcbancar IN reembolsos.cbancar%TYPE,
      pctipban IN reembolsos.ctipban%TYPE,
      pcorigen IN reembolsos.corigen%TYPE)
      RETURN NUMBER;

   FUNCTION f_ins_reemfact(
      pnfact IN OUT reembfact.nfact%TYPE,
      pnreemb IN reembfact.nreemb%TYPE,
      pnfactcli IN reembfact.nfact_cli%TYPE,
      pctipofac IN reembfact.ctipofac%TYPE,   -- BUG10704:DRA:14/07/2009
      pfechafact IN reembfact.ffactura%TYPE,
      pfechacu IN reembfact.facuse%TYPE,
      pimporte IN reembfact.impfact%TYPE,
      porigen IN reembfact.corigen%TYPE DEFAULT 1,
      pfbaja IN reembfact.fbaja%TYPE,
      pncass IN reembfact.ncass_ase%TYPE,
      pncasscli IN reembfact.ncass%TYPE,
      pnfactext IN reembfact.nfactext%TYPE,   -- BUG10631:DRA:03/07/2009
      pctractat IN reembfact.ctractat%TYPE)   -- BUG177321:DRA:22/02/2011
      RETURN NUMBER;

   FUNCTION f_ins_reembactosfac(
      pnreemb IN reembactosfac.nreemb%TYPE,
      pnfact IN reembactosfac.nfact%TYPE,
      pnlinea IN OUT reembactosfac.nlinea%TYPE,
      pcacto IN reembactosfac.cacto%TYPE,
      pnacto IN reembactosfac.nacto%TYPE,
      pfacto IN reembactosfac.facto%TYPE,
      pitarcass IN reembactosfac.itarcass%TYPE,
      ppreemb IN reembactosfac.preemb%TYPE,
      picass IN reembactosfac.icass%TYPE,
      pitot IN reembactosfac.itot%TYPE,
      piextra IN reembactosfac.iextra%TYPE,
      pipago IN reembactosfac.ipago%TYPE,
      piahorro IN reembactosfac.iahorro%TYPE,
      pcerror IN reembactosfac.cerror%TYPE,
      pftrans IN reembactosfac.ftrans%TYPE,
      pcorigen IN reembactosfac.corigen%TYPE,
      pnremesa IN reembactosfac.nremesa%TYPE,
      pfbaja IN reembactosfac.fbaja%TYPE,
      pctipo IN reembactosfac.ctipo%TYPE,   -- BUG10704:DRA:14/07/2009
      pipagocomp IN reembactosfac.ipagocomp%TYPE,   -- BUG10704:DRA:14/07/2009
      pftranscomp IN reembactosfac.ftranscomp%TYPE,   -- BUG10704:DRA:14/07/2009
      pnremesacomp IN reembactosfac.nremesacomp%TYPE)   -- BUG10704:DRA:14/07/2009
      RETURN NUMBER;

   FUNCTION f_act_estado_reemb(pnreemb IN reembolsos.nreemb%TYPE)
      RETURN NUMBER;

   FUNCTION f_valida_estado_reemb(
      pnreemb IN reembolsos.nreemb%TYPE,
      pnuevoestado IN reembolsos.cestado%TYPE)
      RETURN NUMBER;

   FUNCTION f_valida_fecha_fact(
      pnreemb IN reembolsos.nreemb%TYPE,
      pffact IN DATE,
      pfacuse IN DATE)
      RETURN NUMBER;

   /***********************************************************************
      Función que actualizará el estado de impresión de la factura
      param in  pnreemb   : codi del reembossament
      param in  pnfact    : codi estat
      return              : 0 OK     1 ERROR
   ***********************************************************************/
   FUNCTION f_act_factura(pnreemb IN reembfact.nreemb%TYPE, pnfact IN reembfact.nfact%TYPE)
      RETURN NUMBER;

   /***********************************************************************
      Función que hará el traspaso de una factura a un reembolso ya existente
      param in  pnreemb   : codi del reembossament
      param in  pnfact    : codi estat
      param in  pnfactcli : Número factura cliente
      param in  pnreembori: reembolso al cual tenemos que traspasar la factura
      return              : 0 OK     1 ERROR
   ***********************************************************************/
   FUNCTION f_traspasar_factura(
      pnreemb IN reembfact.nreemb%TYPE,
      pnfact IN reembfact.nfact%TYPE,
      pnfactcli IN reembfact.nfact_cli%TYPE,
      pnreembori IN reembfact.nreemb%TYPE)
      RETURN NUMBER;

   /***********************************************************************
      Función que nos dirá si se puede o no modificar la factura
      param in  pnreemb   : codi del reembossament
      param in  pnfact    : codi estat
      return              : 0 OK     1 ERROR
   ***********************************************************************/
   FUNCTION f_modif_factura(
      pnreemb IN reembfact.nreemb%TYPE,
      pnfact IN reembfact.nfact%TYPE,
      pcimpresion OUT reembfact.cimpresion%TYPE)
      RETURN NUMBER;

   /***********************************************************************
      Función para detectar si el nº hoja CASS ya existe
      param in pnreemb    : codi del reembossament
      param in  pnfactcli : codi factura client
      param out pnreembdest  : codi del reembossament
      return              : 0 OK     1 ERROR
   ***********************************************************************/
   FUNCTION f_existe_factcli(
      pnreemb IN reembfact.nreemb%TYPE,
      pnfactcli IN reembfact.nfact_cli%TYPE,
      pnreembdest OUT reembfact.nreemb%TYPE)
      RETURN NUMBER;

   -- BUG10704:DRA:14/07/2009:Inici
   /***********************************************************************
      Función para detectar si la factura es Ordinaria o Complementaria
      param in pnreemb    : codi del reembossament
      param in  pnfact    : codi factura
      return              : 0 OK     1 ERROR
   ***********************************************************************/
   FUNCTION f_tipo_factura(
      pnreemb IN reembfact.nreemb%TYPE,
      pnfact IN reembfact.nfact%TYPE)
      RETURN NUMBER;

-- BUG10704:DRA:14/07/2009:Fi
-- BUG10949:JGM:19/08/2009:Fi
   /***********************************************************************
      Función para detectar si la factura tiene fecha de baja y cual
      param in pnreemb    : codi del reembossament
      param in  pnfact    : codi factura
      fbaja out  date    : data baixa
      return              : 0 OK     1 ERROR
   ***********************************************************************/
   FUNCTION f_get_data_baixa(pnreemb IN NUMBER, pnfact IN NUMBER, pfbaja OUT DATE)
      RETURN NUMBER;

   -- BUG10949:JGM:19/08/2009:Fi

   -- BUG17732:DRA:22/02/2011:Inici
   /***********************************************************************
      Función para modificar la CCC del reembolso
      param in pnreemb    : codi del reembossament
      param in pcbancar   : codi CCC
      return              : 0 OK     num_lit ERROR
   ***********************************************************************/
   FUNCTION f_modificar_ccc(pnreemb IN NUMBER, pcheck IN NUMBER, pcbancar IN VARCHAR2)
      RETURN NUMBER;

   /***********************************************************************
      Función para retornar la CCC a grabar en el reembolso
      param in psseguro   : Identificador del seguro
      param in pnreemb    : codi del reembossament
      param out pctipban  : codi tipus banc
      param out pcbancar  : codi CCC
      return              : 0 OK     num_lit ERROR
   ***********************************************************************/
   FUNCTION f_obtener_ccc(
      psseguro IN NUMBER,
      pnreemb IN NUMBER,
      pctipban OUT NUMBER,
      pcbancar OUT VARCHAR2)
      RETURN NUMBER;
-- BUG17732:DRA:22/02/2011:Fi
END pac_reembolsos;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_REEMBOLSOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_REEMBOLSOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_REEMBOLSOS" TO "PROGRAMADORESCSI";
