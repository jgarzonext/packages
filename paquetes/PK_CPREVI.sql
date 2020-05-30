--------------------------------------------------------
--  DDL for Package PK_CPREVI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PK_CPREVI" AS
   sortir         BOOLEAN := FALSE;
   perror         NUMBER;
   -- Parámetros para WIN.
   polissa        VARCHAR2(10);   -- CASER
   --NUM_CERTIF  VARCHAR2(10);
   nif_cli        VARCHAR2(10);
   lletra_nif     VARCHAR2(1);
   dataefec       VARCHAR2(8);
   datavencim     VARCHAR2(8);
   primaneta      VARCHAR2(20);   -- CASER
   consorci       VARCHAR2(20);
   rec_extern     VARCHAR2(20);
   tasas          VARCHAR2(20);
   primabruta     VARCHAR2(20);
   continent      VARCHAR2(20);   -- CASER
   contingut      VARCHAR2(20);   -- CASER
   comissio       VARCHAR2(20);
   producte       VARCHAR2(6);   -- CASER
   -- Parámetros para CASER.
   cia            VARCHAR2(4);
   blanc          VARCHAR2(4);
   rebut          VARCHAR2(7);
   pol_colec      VARCHAR2(10);
   --POLISSA       VARCHAR2(10);  -- WIN
   ram            VARCHAR2(8);
   modalitat      VARCHAR2(2);
   sub_moda       VARCHAR2(3);
   AGENT          VARCHAR2(7);
   d_refecte      VARCHAR2(6);
   d_rvencim      VARCHAR2(6);
   --PRIMANETA   VARCHAR2(11);  -- WIN
   rec_exter      VARCHAR2(20);
   impostos       VARCHAR2(20);
   --CONSORCI    VARCHAR2(9);
   bonifica       VARCHAR2(20);
   dgs            VARCHAR2(20);
   arbitrio       VARCHAR2(20);
   fng            VARCHAR2(20);
   d_pefecte      VARCHAR2(6);
   tip_comis      VARCHAR2(1);
   anys_comis     VARCHAR2(3);
   comi_agent     VARCHAR2(10);
   com_reca       VARCHAR2(3);
   reten_comi     VARCHAR2(3);
   om             VARCHAR2(7);
   prefix_cif     VARCHAR2(1);
   n_docu         VARCHAR2(10);
   nom_cli        VARCHAR2(45);
   domicili       VARCHAR2(45);
   provincia      VARCHAR2(20);
   poblacio       VARCHAR2(31);
   cp             VARCHAR2(5);
   dura_pol       VARCHAR2(2);
   forma_paga     VARCHAR2(2);
   ind_inx        VARCHAR2(7);
   matricula      VARCHAR2(8);
   --CONTINENT   VARCHAR2(13);  -- WIN
   --CONTINGUT   VARCHAR2(13);  -- WIN
   avmaqui        VARCHAR2(20);
   detalime       VARCHAR2(20);
   refer_pc       VARCHAR2(11);
   compte         VARCHAR2(45);
   soporte        VARCHAR2(1);
   num_soport     VARCHAR2(3);
   centro_cob     VARCHAR2(4);
   agent_cob      VARCHAR2(4);
   enti_benef     VARCHAR2(1);
   refer_domi     VARCHAR2(12);
   codi_emis      VARCHAR2(1);
   d_emissio      VARCHAR2(6);
   codi_liqui     VARCHAR2(1);
   d_liquida      VARCHAR2(6);
   motiu_anul     VARCHAR2(3);
   prod_cart      VARCHAR2(1);
   --PRODUCTE    VARCHAR2(6);  -- WIN
   cramo          VARCHAR2(8);
   cmodali        VARCHAR2(2);
   ctipseg        VARCHAR2(2);
   ccolect        VARCHAR2(2);
   -- Se busca el sseguro para insertarlo en la tabla.
   sseguro        VARCHAR2(6);
   -- Indica si se está tratando un fichero Caser ('C') o Winterthur ('W').
   tipo           VARCHAR2(1);

   PROCEDURE tractar;

   PROCEDURE llegir;

   PROCEDURE comprovar;
END pk_cprevi;
 

/

  GRANT EXECUTE ON "AXIS"."PK_CPREVI" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_CPREVI" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_CPREVI" TO "PROGRAMADORESCSI";
