--------------------------------------------------------
--  DDL for Package PAC_BORRAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_BORRAR" authid current_user IS
  PROCEDURE borrar_tablas_seguros
            (psseguro IN NUMBER);
  PROCEDURE borrar_recibos
            (psseguro IN NUMBER, mens OUT VARCHAR2);
  PROCEDURE borrar_siniestros
            (psseguro IN NUMBER, mens OUT VARCHAR2);
  PROCEDURE borrar_garantias
            (pnsinies IN NUMBER, mens OUT VARCHAR2);
  PROCEDURE borrar_pagos
            (pnsinies IN NUMBER, mens OUT VARCHAR2);
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_BORRAR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_BORRAR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_BORRAR" TO "PROGRAMADORESCSI";
