--------------------------------------------------------
--  DDL for Package Body PAC_RECIBOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_RECIBOS" IS
   /******************************************************************************
     NOMBRE:      PAC_RECIBOS
     PROPÓSITO:   Funciones y procedimientos relacionados con recibos
                  y tarificacion
     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        28/02/2014   dlF              1. Creación del package.
   ******************************************************************************/

   /****************************************************************************
     ff_recries: Calcula el recibo del suplemento de seguro.
           pctipreb = 1 => Por tomador   (Solo un recibo)
           pctipreb = 2 => Por asegurado (Tantos recibos como riesgos haya)
           pctipreb = 3 => Por colectivo (Un recibo al tomador) Luego se pasa un prceso
                                       que junta los recibos por póliza incluyendo los certificados.
           pctipreb = 4 => Rebut per aportant (taula aportaseg)
           pnProceso = NULL => lanza el calculo de los importes de suplemento.
           psImporte = PRIMA_NETA , IMPUESTOS , PRIMA_RECIBO
     1.- Devuelve error o numero de proceso
     2.- Solo en modo PREVIO.
   ****************************************************************************/
   FUNCTION ff_recries(
      psseguro NUMBER,
      pnmovimiento NUMBER,
      pnproceso NUMBER DEFAULT NULL,
      psimporte VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      nreturn        NUMBER;
      nimporte       NUMBER;
      nproceso       PLS_INTEGER;
      ntiporecibo    NUMBER(1);
      nagente        NUMBER;
      defectosupl    DATE;
      dcartera       DATE;
      nempresa       PLS_INTEGER;
      ncobbancario   NUMBER;
      nsitpoliza     NUMBER(2);
      ndomper        NUMBER(1);
      nejecucion     NUMBER(3);
      xcmodcom       NUMBER;   --XVM-BUG35200
   BEGIN
      nejecucion := 0;

      IF pnproceso IS NOT NULL THEN
         nejecucion := 10;

         SELECT CASE r.ctiprec
                   WHEN 9 THEN CASE psimporte
                                 WHEN 'PRIMA_NETA' THEN iprinet * -1
                                 WHEN 'IMPUESTOS' THEN (iconsor + itotimp) * -1
                                 WHEN 'PRIMA_RECIBO' THEN itotalr * -1
                                 ELSE 0
                              END
                   ELSE CASE psimporte
                   WHEN 'PRIMA_NETA' THEN iprinet
                   WHEN 'IMPUESTOS' THEN(iconsor + itotimp)
                   WHEN 'PRIMA_RECIBO' THEN itotalr
                   ELSE 0
                END
                END
           INTO nreturn
           FROM reciboscar r, vdetreciboscar v
          WHERE r.sproces = v.sproces
            AND r.nrecibo = v.nrecibo
            AND r.sproces = pnproceso
            AND r.sseguro = psseguro;

         nejecucion := 20;
      ELSE
         nejecucion := 30;
         nreturn := f_procesini(f_user, 10, 'EMISION', 'Emisión de suplemento', nproceso);
         nejecucion := 40;

         IF nreturn = 0 THEN
            nejecucion := 50;

            SELECT s.ctipreb, s.cagente, m.fefecto,
                   NVL(s.fcaranu, ADD_MONTHS(s.fefecto, 12)) fvencimi, s.cempres, s.ccobban,
                   s.csituac, m.cdomper
              INTO ntiporecibo, nagente, defectosupl,
                   dcartera, nempresa, ncobbancario,
                   nsitpoliza, ndomper
              FROM seguros s, movseguro m
             WHERE m.sseguro = s.sseguro
               AND s.sseguro = psseguro
               AND m.nmovimi = pnmovimiento;

            nejecucion := 60;

            IF f_es_renovacion(psseguro) = 0 THEN   --XVM-BUG35200
               xcmodcom := 2;
            ELSE   -- si es 1 es nueva produccion
               xcmodcom := 1;
            END IF;

            nreturn :=
               f_recries
                  (pctipreb => ntiporecibo,   -- ctipreb from SEGUROS
                                           psseguro => psseguro,   -- sseguro from SEGUROS
                                                                pcagente => nagente,   -- cagente from SEGUROS
                   pfemisio => f_sysdate,   -- fecha del sistema
                                         pfefecto => defectosupl,   --  efecto del suplemento
                                                                 pfvencimi => dcartera,   -- efecto de la CARTERA ( supongo )  fcaranu from seguros
                   pctiprec => 1,   --  lctiprec := 1;   --Suplemento
                                 pnanuali => NULL, pnfracci => NULL, pccobban => ncobbancario,   --puede ser NULL
                   pcestimp => NULL,   --NULL
                                    psproces => nproceso,   -- nº de proceso
                                                         ptipomovimiento => 1,   --1 suplemento
                                                                              pmodo => 'P',   -- 'P' Previo
                   pcmodcom => xcmodcom,   -- modo comision - 1 = Produccion, 2 = Cartera
                                        pfcaranu => dcartera,   -- fecha renovacion cartera
                                                             pnimport => 0,   -- 0
                                                                           pcmovimi => 2,   -- parametro PCMOVIMI para pasarselo a f_insrecibo.
                                                                                            --    Nos indica si es producto es de ahorro(pcmovimi not null)
                                                                                            --       o no lo es (pcmovimi = null)
                   pcempres => nempresa,   -- empresa ( piuede ser null
                                        pnmovimi => pnmovimiento,   -- movimiento del seguro
                                                                 pcpoliza => nsitpoliza,   -- csituac from seguros
                   pnimport2 => nimporte,   -- OUT -----
                                         pnordapo => NULL,   -- DEFAULT NULL
                                                          pcgarant => NULL, pttabla => NULL,
                   pfuncion => 'CAR',   --'CAR' aparentemente siempre es CAR
                                     pcdomper => ndomper);   --cdomper from movseguro
            nejecucion := 70;
         END IF;
      END IF;

      nejecucion := 80;

      IF pnproceso IS NULL
         AND nreturn = 0 THEN
         nejecucion := 90;

         SELECT CASE
                   WHEN COUNT(1) = 0 THEN 0
                   ELSE nproceso
                END
           INTO nreturn
           FROM reciboscar r
          WHERE r.sproces = nproceso
            AND r.sseguro = psseguro;

         nejecucion := 95;
      END IF;

      nejecucion := 100;
      COMMIT;
      RETURN nreturn;
   EXCEPTION
      WHEN OTHERS THEN
         nejecucion := 999;
         p_tab_error(pferror => f_sysdate, pcusuari => f_user,
                     ptobjeto => 'psSeguro : ' || psseguro || ' - pnMovimiento: '
                      || pnmovimiento || ' - pnProceso: ' || pnproceso || ' - psImporte: '
                      || psimporte || ' - nReturn: ' || nreturn || ' - nProceso: ' || nproceso,
                     pntraza => nejecucion, ptdescrip => 'Excepcion en ff_recries',
                     pterror => SQLERRM);
         COMMIT;
         RETURN 0;
   END;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_RECIBOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_RECIBOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_RECIBOS" TO "PROGRAMADORESCSI";
