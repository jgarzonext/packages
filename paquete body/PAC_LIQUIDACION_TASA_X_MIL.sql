--------------------------------------------------------
--  DDL for Package Body PAC_LIQUIDACION_TASA_X_MIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_LIQUIDACION_TASA_X_MIL" 
AS
/******************************************************************************
    NOMBRE:      PAC_LIQUIDACION_TASA_X_MIL
    PROP¿SITO:   LIQUIDACION DE TASA POR MIL

    REVISIONES:
    Ver        Fecha        Autor             Descripci¿n
    ---------  ----------  ---------------  ------------------------------------
    1.0        21/12/2016   FFO                1. Creaci¿n del package.*/


     /*************************************************************************

  /*
      pcmodo :=  1 - REAL, 0 PREVIO
  */
  FUNCTION LIQUIDACION_TASA_X_MIL(
      pcmodo                IN       NUMBER,
      pcempresa             IN       NUMBER,
      pcagente              IN       NUMBER,
      pcsucursal            IN       NUMBER,
      pfdesde               IN       DATE,
      pfhasta               IN       DATE
   ) RETURN NUMBER IS
    vpasexec    NUMBER;
	  vnumerr     NUMBER;
	  vparam      VARCHAR2(1000);
	  vobjectname VARCHAR2(200):='PAC_LIQUIDACION_TASA_X_MIL.LIQUIDACION_TASA_X_MIL';

    CURSOR c_tadaxmil IS
      SELECT CAGENTE, SPROCES, NVL(DEBITO, 0) DEBITO, NVL(CREDITO, 0) CREDITO, (NVL(DEBITO, 0) - NVL(CREDITO, 0)) NETO, ((NVL(DEBITO, 0) - NVL(CREDITO, 0))*0.004)  ITXMIL FROM(
          SELECT C.CAGENTE, C.SPROCES, SUM((SELECT c1.IIMPORT
                              FROM ctactes c1
                             WHERE c1.CEMPRES=c.CEMPRES
                               AND c1.CAGENTE=c.CAGENTE
                               AND c1.NNUMLIN=c.NNUMLIN
                               AND c1.cdebhab=1))DEBITO,
                            SUM((SELECT c1.IIMPORT
                              FROM ctactes c1
                             WHERE c1.CEMPRES=c.CEMPRES
                               AND c1.CAGENTE=c.CAGENTE
                               AND c1.NNUMLIN=c.NNUMLIN
                               AND c1.cdebhab=2)) CREDITO
          FROM ctactes c, liquidacab l
          WHERE  c.sproces = l.sproliq
          AND C.cconcta IN (99)
          AND C.CAGENTE = nvl(pcagente, C.CAGENTE)
          AND pac_agentes.F_get_cageliq(24, 2, c.cagente) = nvl(pcsucursal, pac_agentes.F_get_cageliq(24, 2, c.cagente))
          GROUP BY C.CAGENTE, C.SPROCES);



  BEGIN

  FOR var IN c_tadaxmil LOOP
        IF pcmodo = 0 THEN

            INSERT INTO CONTAB_4XMIL
            (
              NSUCUR,
              CCUENTA,
              SDTOCORTE ,
              CAGENTE,
              IDEBITO,
              ICREDITO,
              INETO,
              ITXMIL,
              CEMPRES,
              FCONTA,
              FTRASPASO,
              CPROCES
            )
            VALUES
            (
              nvl(pac_agentes.f_get_cageliq(pcempresa, 2, var.CAGENTE), nvl(pcsucursal, 0)),
              0,
              LPAD(pac_agentes.f_get_cageliq(pcempresa, 2, var.CAGENTE),4)||LPAD(S_TASAXMIL.NEXTVAL,8,0),
              var.CAGENTE,
              var.DEBITO,
              var.CREDITO,
              var.NETO,
              var.ITXMIL,
              pcempresa,
              pfdesde,
              pfhasta,
              var.SPROCES
            );

        ELSE
          INSERT INTO CONTAB_4XMIL_PRE
            (
              NSUCUR,
              CCUENTA,
              SDTOCORTE,
              CAGENTE,
              IDEBITO,
              ICREDITO,
              INETO,
              ITXMIL,
              CEMPRES,
              FCONTA,
              FTRASPASO,
              CPROCES
            )
            VALUES
            (
              nvl(pac_agentes.f_get_cageliq(pcempresa, 2, var.CAGENTE), nvl(pcsucursal, 0)),
              0,
              LPAD(pac_agentes.f_get_cageliq(pcempresa, 2, var.CAGENTE),4)||LPAD(S_TASAXMIL.NEXTVAL,8,0),
              var.CAGENTE,
              var.DEBITO,
              var.CREDITO,
              var.NETO,
              var.ITXMIL,
              pcempresa,
              pfdesde,
              pfhasta,
              var.SPROCES
            );
          END IF;
    END LOOP;
    RETURN 0;
  EXCEPTION
	  WHEN OTHERS THEN
               p_control_error('ffo','error','prueba: '||SQLERRM);
	             p_tab_error(f_sysdate, f_user, vobjectname, 1, vobjectname, SQLERRM);
               RETURN 1000006;
	END LIQUIDACION_TASA_X_MIL;


END PAC_LIQUIDACION_TASA_X_MIL;

/

  GRANT EXECUTE ON "AXIS"."PAC_LIQUIDACION_TASA_X_MIL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_LIQUIDACION_TASA_X_MIL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_LIQUIDACION_TASA_X_MIL" TO "PROGRAMADORESCSI";
