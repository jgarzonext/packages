--------------------------------------------------------
--  DDL for Package PAC_RECIBOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_RECIBOS" IS

    /******************************************************************************
      NOMBRE:      PAC_RECIBOS
      PROPÓSITO:   Funciones y procedimientos relacionados con recibos
                   y tarificacion
      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        28/02/2014   dlF              1. Creación del package.
    ******************************************************************************/

    /*************************************************************************
          Calcula un recibo de suplemento en modo PREVI
          param    psSeguro      : seguro
          param    pnMovimiento  : movimiento del seguro
          param    pnProceso     : numero de preoceso
          param    psImporte     : tipo de importe requerido

          retorna nmumero de proceso si pnProceso IS NULL,
                  importe si pnProceso IN NOT NULL
                  0 si error
    *************************************************************************/
    FUNCTION ff_recries( psSeguro      NUMBER,
                         pnMovimiento  NUMBER,
                         pnProceso     NUMBER DEFAULT NULL,
                         psImporte     VARCHAR2 DEFAULT NULL
                       ) RETURN NUMBER ;

END;

/

  GRANT EXECUTE ON "AXIS"."PAC_RECIBOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_RECIBOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_RECIBOS" TO "PROGRAMADORESCSI";
