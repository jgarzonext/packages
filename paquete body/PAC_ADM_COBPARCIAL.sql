/* Formatted on 2020/05/07 15:07 (Formatter Plus v4.8.8) */
CREATE OR REPLACE PACKAGE BODY pac_adm_cobparcial
AS
/************************************************************************************************
   NOMBRE:      PAC_ADM_COBPARCIAL
   PROPÓSITO:   Nuevo paquete de la capa lógica que tendrá las funciones la gestiones
                con cobros parciales de recibos.

   REVISIONES:
   Ver  Fecha       Autor    Descripción
   ---  ----------  -------  ----------------------------------------------------------------------
   1.0  26/09/2012  JGR      0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 (creación pack)
   2.0  25/10/2012  JGR      0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - 0127248
   3.0  08/10/2012  JGR      0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - 0127366
   4.0  19/10/2012  DCG      0023130: LCOL_F002-Provisiones para polizas estatales
   5.0  04/03/2013  JGR      0026022: LCOL: Liquidaciones de Colectivos - 0139541
   6.0  13/03/2013  AFM      0026301: RSA002 - Carga IPC. Añadir fichero de pagos. Se añade la
                                      función f_carga_pagos_masiva.
   7.0  21/03/2013  AFM      0025951: RSA003 - Módulo de cobranza
   8.0  14/05/2013  DCG      0026959: RSA701-Informar correctamente los importes de los cobros parciales en multimoneda.
   9.0  10/06/2013  AFM      0027190: Generar desglose por garantía y concepto de los pagos parciales.
  10.0  30/07/2013  DCG      0026959: RSA701-Informar correctamente los importes de los cobros parciales en multimoneda.
                                      Para LCOL se cobra en la moneda contable.
                                      Para RSA se cobra en la moneda del producto.
  11.0  05/08/2013  JGR      0025611: (POSDE100)-Desarrollo-GAPS Administracion-Id 1 - Manejo de pagos de ARP
  12.0  18/09/2013  JGR      0028206: LCOL_PROD-Revision de mensajes en TxNoPago y otros package
  13.0  10-10-2013  JMF      0028517: RSA998 - CAJA. Pago de recibos requiere recaudación
  14.0  22-10-2013  JGR      0028577: POSND100-Añadir nota en la agenda del recibo en el momento de que SAP nos envie un recaudo. Nota:0156387
  15.0  29-10-2013  AFM      0028517: RSA998 - CAJA. Pago de recibos requiere recaudación
  16.0  24-12-2013  MMM      0029431: LCOL_MILL-10603: Al reactivar una poliza, el sistema debe conservar toda la informacion q venia en la poliza inicial, sin actual
  17.0  04/02/2015  MDS      0032674: COLM004-Guardar los importes de recaudo a la fecha de recaudo
  18.0  17/06/2019  JLTS     IAXIS.4153: Se incluyen nuevos paráametros pnreccaj y pcmreca a la función f_set_detmovrecibo
  19.0  18/07/2019  JLTS     IAXIS-4518: Se ajustan algunos campos por redondeo.
  20.0  18/07/2019 Shakti    IAXIS-4753: Ajuste campos Servicio L003
  21.0  01/08/2019 Shakti    IAXIS-4944 TAREAS CAMPOS LISTENER
  22.0  12/09/2019  DFRP     IAXIS-4884: Paquete de integración pagos SAP
  23.0  23/10/2019  DFRP     IAXIS-4926: Anulación de póliza y movimientos con recibos abonados y Reversión de recaudos en recibos.
  15.0  04/12/2019  DFRP     IAXIS-7640: Ajuste paquete listener para Recaudos SAP
  16.0  06/04/2020  JLTS     IAXIS-7584: Adicion de la función f_get_importe_cobrado ( Para el reporte DetEmisRecibos.jasper)
  17.0  06/05/2020  ECP      IAXIS-13889.No recauda el saldo del prorrateo en los recibos cancelados por no pago
   ************************************************************************************************/
   e_object_error   EXCEPTION;
   e_param_error    EXCEPTION;

   /*******************************************************************************
   FUNCION PAC_ADM_COBPARCIAL.F_GET_IMPORTE_COBRO_PARCIAL
   Indica si un recibo tiene cobro parcial devolviendo el importe de los cobros parciales realizados

   Parámetros:
      param in psmovrec   : Secuencial del movimiento
      param in pnorden    : Número de movimiento

      return: number con el importe del cobro parcial.
              > 0 cuando sí hay pagos.
              = 0 cuando no hay pagos,la suma de estos es 0 o error
   ********************************************************************************/
   FUNCTION f_get_importe_cobro_parcial (
      pnrecibo   IN   NUMBER,
      psmovrec   IN   NUMBER DEFAULT NULL,
      pnorden    IN   NUMBER DEFAULT NULL,
      pimoncon   IN   NUMBER DEFAULT NULL
   )                                        -- Bug 0026959 - DCG - 30/07/2013
      RETURN NUMBER
   IS
      viimporte          NUMBER          := 0;
      vsmovrec           NUMBER          := psmovrec;
      vobject            VARCHAR2 (200)
                          := 'pac_adm_cobparcial.f_get_importe_cobro_parcial';
      terror             VARCHAR2 (200);
      vpasexec           NUMBER (8)      := 1;
      vparam             VARCHAR2 (2000)
         :=    'pnrecibo:'
            || pnrecibo
            || ' psmovrec:'
            || psmovrec
            || ' pnorden:'
            || pnorden
            || ' pimoncon:'
            || pimoncon;                     -- Bug 0026959 - DCG - 30/07/2013
      vimp               NUMBER;             -- Bug 0026959 - DCG - 30/07/2013
      vimp_moncon        NUMBER;             -- Bug 0026959 - DCG - 30/07/2013
      -- Ini IAXIS-13889 -- 06/05/2020
      v_sum_importe      NUMBER;
      v_sum_impuesto     NUMBER;
      v_sum_gastos       NUMBER;
      v_sum_impcom       NUMBER;
      v_itotalr          NUMBER;
      v_itotalr_monpol   NUMBER;
      v_sum_comis        NUMBER;
      v_cmotmov          NUMBER;
   BEGIN
      vpasexec := 1;

      SELECT m.cmotmov, d.itotalr, v.itotalr itotalr_monpol
        INTO v_cmotmov, v_itotalr, v_itotalr_monpol
        FROM recibos r,
             seguros s,
             vdetrecibos_monpol v,
             movrecibo m,
             vdetrecibos d,
             productos p
       WHERE r.nrecibo = pnrecibo
         AND d.nrecibo = r.nrecibo
         AND v.nrecibo = r.nrecibo
         AND m.nrecibo = r.nrecibo
         AND m.fmovfin IS NULL
         AND r.sseguro = s.sseguro
         AND s.sproduc = p.sproduc;

      IF v_cmotmov = 321
      THEN
         BEGIN
            SELECT NVL (SUM (b.iconcep_monpol), SUM (b.iconcep))
              INTO v_sum_importe
              FROM detmovrecibo a, detmovrecibo_parcial b
             WHERE a.nrecibo = pnrecibo
               AND a.nrecibo = b.nrecibo
               AND a.smovrec = (SELECT MAX (b.smovrec)
                                  FROM detmovrecibo b
                                 WHERE b.nrecibo = a.nrecibo)
               AND a.norden = b.norden
               AND b.cconcep IN (0, 50);     -- IAXIS-4995 - JLTS - 08/08/2019
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_sum_importe := 0;
         END;

         v_sum_importe := NVL (v_sum_importe, 0);

         BEGIN
            SELECT NVL (SUM (b.iconcep_monpol), SUM (b.iconcep))
              INTO v_sum_gastos
              FROM detmovrecibo a, detmovrecibo_parcial b
             WHERE a.nrecibo = pnrecibo
               AND a.nrecibo = b.nrecibo
               AND a.smovrec = (SELECT MAX (b.smovrec)
                                  FROM detmovrecibo b
                                 WHERE b.nrecibo = a.nrecibo)
               AND a.norden = b.norden
               AND b.cconcep IN (14);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_sum_gastos := 0;
         END;

         v_sum_gastos := NVL (v_sum_gastos, 0);

         BEGIN
            SELECT NVL (SUM (b.iconcep_monpol), SUM (b.iconcep))
              INTO v_sum_impuesto
              FROM detmovrecibo a, detmovrecibo_parcial b
             WHERE a.nrecibo = pnrecibo
               AND a.nrecibo = b.nrecibo
               AND a.smovrec = (SELECT MAX (b.smovrec)
                                  FROM detmovrecibo b
                                 WHERE b.nrecibo = a.nrecibo)
               AND a.norden = b.norden
               AND b.cconcep IN (4, 86);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_sum_impuesto := 0;
         END;

         v_sum_impuesto := NVL (v_sum_impuesto, 0);

         BEGIN
            SELECT NVL (SUM (b.iconcep_monpol), SUM (b.iconcep))
              INTO v_sum_impcom
              FROM detmovrecibo a, detmovrecibo_parcial b
             WHERE a.nrecibo = pnrecibo
               AND a.nrecibo = b.nrecibo
               AND a.smovrec = (SELECT MAX (b.smovrec)
                                  FROM detmovrecibo b
                                 WHERE b.nrecibo = a.nrecibo)
               AND a.norden = b.norden
               AND b.cconcep IN (32, 82);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_sum_impcom := 0;
         END;

         v_sum_impcom := NVL (v_sum_impcom, 0);

         BEGIN
            SELECT NVL (SUM (b.iconcep_monpol), SUM (b.iconcep))
              INTO v_sum_comis
              FROM detmovrecibo a, detmovrecibo_parcial b
             WHERE a.nrecibo = pnrecibo
               AND a.nrecibo = b.nrecibo
               AND a.smovrec = (SELECT MAX (b.smovrec)
                                  FROM detmovrecibo b
                                 WHERE b.nrecibo = a.nrecibo)
               AND a.norden = b.norden
               AND b.cconcep IN (11);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_sum_comis := 0;
         END;

         v_sum_comis := NVL (v_sum_comis, 0);
         vpasexec := 10;

         IF pimoncon = 1
         THEN
            viimporte :=
                 v_itotalr_monpol
               - v_sum_importe
               - v_sum_impuesto
               - v_sum_gastos;
               
         ELSE
            viimporte :=
                 v_itotalr
               - v_sum_importe
               - v_sum_impuesto
               - v_sum_gastos;
               
         END IF;
         
      ELSE
         IF vsmovrec IS NULL
         THEN
            IF pnrecibo IS NULL
            THEN
               vpasexec := 20;
               RAISE e_param_error;
            ELSE
               vpasexec := 30;

               SELECT MAX (smovrec)
                 INTO vsmovrec
                 FROM movrecibo
                WHERE nrecibo = pnrecibo AND cestrec = 0;
            END IF;
         END IF;

         IF vsmovrec IS NOT NULL
         THEN
            vpasexec := 40;

            -- Bug 0026959 - DCG - 30/07/2013 Inici
            SELECT NVL (SUM (iimporte_moncon), 0), NVL (SUM (iimporte), 0)
              INTO vimp_moncon, vimp
              FROM detmovrecibo
             WHERE norden = NVL (pnorden, norden)
               AND nrecibo = pnrecibo
               AND smovrec = vsmovrec;                -- IAXIS-4926 23/10/2019

            IF pimoncon = 1
            THEN
               viimporte := vimp_moncon;
            ELSE
               viimporte := vimp;
            END IF;
         -- Bug 0026959 - DCG - 30/07/2013 Fi
         END IF;
      END IF;
-- Fin IAXIS-13889 -- 06/05/2020
      vpasexec := 50;
      RETURN viimporte;
   EXCEPTION
      WHEN e_param_error
      THEN
         p_tab_error (f_sysdate, f_user, vobject, vpasexec, vparam, 1000005);
         RETURN 0;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 0;
   END f_get_importe_cobro_parcial;

   --
   -- Inicio IAXIS-4884 12/09/2019
   --
   FUNCTION f_inserta_detmovrecibo_parcial (
      pnrecibo          IN   NUMBER,
      pcconcep          IN   NUMBER,
      pcgarant          IN   NUMBER,
      pnriesgo          IN   NUMBER,
      psmovrec          IN   NUMBER,
      pitasa            IN   NUMBER,
      pcmonins          IN   NUMBER,
      pitotalr          IN   NUMBER,
      piimporte         IN   NUMBER,
      piconcep          IN   NUMBER,
      pcdivisa          IN   NUMBER,
      pimpparctot       IN   NUMBER,
      piconcep_monpol   IN   NUMBER,
      piimpmon          IN   NUMBER,
      pnorden           IN   NUMBER,
      pfcambio          IN   DATE,
      pnreccaj          IN   VARCHAR2,
      pcmreca           IN   NUMBER,
      pctipotransap     IN   NUMBER
   )
      RETURN NUMBER
   IS
      --
      vobjectname         VARCHAR2 (500)
                       := 'pac_adm_cobparcial.f_inserta_detmovrecibo_parcial';
      vparam              VARCHAR2 (2000)
         :=    'parámetros - pnrecibo: '
            || pnrecibo
            || ' pcconcep:'
            || pcconcep
            || ' pcgarant:'
            || pcgarant
            || ' pnriesgo:'
            || pnriesgo
            || ' psmovrec:'
            || psmovrec
            || ' pitasa:'
            || pitasa
            || ' pcmonins:'
            || pcmonins
            || ' pitotalr:'
            || pitotalr
            || ' piimporte:'
            || piimporte
            || ' piconcep:'
            || piconcep
            || ' pcdivisa:'
            || pcdivisa
            || ' pimpparctot:'
            || pimpparctot
            || ' piconcep_monpol:'
            || piconcep_monpol
            || ' piimpmon:'
            || piimpmon
            || ' pnorden:'
            || pnorden
            || ' pfcambio:'
            || pfcambio
            || ' pnreccaj:'
            || pnreccaj
            || ' pcmreca:'
            || pcmreca
            || ' pctipotransap:'
            || pctipotransap;
      pasexec             NUMBER;
      viconcep            NUMBER;
      viconcep_monpol     NUMBER;
      sql_stmt            VARCHAR2 (500);
      vtotimpcon          NUMBER;
      vtotimpcon_monpol   NUMBER;
   --
   BEGIN
      --
      pasexec := 0;
      viconcep := 0;
      viconcep_monpol := 0;
      --
      sql_stmt :=
            'SELECT NVL(SUM(d.iconcep),0),NVL(SUM(d.iconcep_monpol),0)
                   FROM detrecibos d
                  WHERE d.nrecibo = '
         || pnrecibo;

      --
      IF pctipotransap = 11
      THEN
         sql_stmt := sql_stmt || ' AND d.cconcep IN (0,50)';
      ELSIF pctipotransap = 12
      THEN
         sql_stmt := sql_stmt || ' AND d.cconcep IN (4,86)';
      ELSE
         sql_stmt := sql_stmt || ' AND d.cconcep = 14';
      END IF;

      --
      pasexec := 10;

      EXECUTE IMMEDIATE sql_stmt
                   INTO vtotimpcon, vtotimpcon_monpol;

      --
      -- Al ser el último parcial, que completa total de recibo, se hace por diferencia para q cuadre
      IF pimpparctot = pitotalr
      THEN
         --
         pasexec := 20;

         --
         SELECT NVL (SUM (NVL (iconcep, 0)), 0)
           INTO viconcep
           FROM detmovrecibo_parcial
          WHERE nrecibo = pnrecibo
            AND cconcep = pcconcep
            AND cgarant = pcgarant
            AND nriesgo = pnriesgo
            AND smovrec = psmovrec;

         --
         viconcep := piconcep - viconcep;

         --contravalor viconcep pra infor el viconcep_monpol
         IF pitasa IS NULL
         THEN
            viconcep_monpol := viconcep;
         ELSE
            pasexec := 30;
            viconcep_monpol :=
                            pac_monedas.f_round (viconcep * pitasa, pcmonins);
         END IF;
      --
      ELSE                                       -- Se calcula por proporcion.
         --
         pasexec := 40;
         --
         viconcep := f_round ((piconcep / vtotimpcon) * piimporte, pcdivisa);
         --
         pasexec := 50;
         --
         viconcep_monpol :=
            f_round ((piconcep_monpol / vtotimpcon_monpol) * piimpmon,
                     pcmonins
                    );
      --
      END IF;

      --
      IF viconcep <> 0
      THEN
         --
         pasexec := 60;

         --
         INSERT INTO detmovrecibo_parcial
                     (smovrec, norden, nrecibo, cconcep,
                      cgarant, nriesgo, iconcep,
                      iconcep_monpol, fcambio, nreccaj, cmreca
                     )
              VALUES (psmovrec, pnorden, pnrecibo, pcconcep,
                      NVL (pcgarant, 9999), pnriesgo, viconcep,
                      viconcep_monpol, pfcambio, pnreccaj, pcmreca
                     );                               -- IAXIS-7640 04/12/2019
      --
      END IF;

      --
      RETURN 0;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      pasexec,
                      vparam,
                      'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 1;
   END f_inserta_detmovrecibo_parcial;

   --
   -- Fin IAXIS-4884 12/09/2019
   --
   /*************************************************************************
    FUNCTION f_set_detmovrecibo
      Inserta a la tabla DETMOVRECIBO, para informar los pagos parciales de recibos.

      PARAMETROS:

        PNRECIBO   N NUMBER(9)      Número de recibo.
        PSMOVREC   N NUMBER(8)      Secuencial del movimiento
        PNORDEN    N NUMBER         Número de movimiento --> Solo informar para UPDATE
        PIIMPORTE  N NUMBER(13,2)   Importe Cobrado
        PFMOVIMI   N DATE           Fecha de movimiento
        PFEFEADM   S DATE           Fecha efecto del movimiento a nivel administrativo
        PCUSUARI   N VARCHAR2(34)   Usuario que realiza el movimiento
        PSDEVOLU   N NUMBER (9)     Secuencia de devolucion
        PNNUMNLIN  N NUMBER(10)     Número de línea
        PCBANCAR1  N VARCHAR2(50)   Cuenta destinataria
        PNNUMORD   N NUMBER(10)     Número de orden
        PSMOVRECR  S NUMBER(8)      Secuencial del movimiento Recíproco
        PNORDENR   S NUMBER(2)      Número de movimiento Recíproco
        PTDESCRIP  S VARCHAR2(1000) Descripció de l'apunt del rebut
        PIIMPMON   S NUMBER(13,2)   Importe Cobrado en moneda contable
        PSPROCES   S NUMBER         Número de Proceso

           return             : 0 -> Tot correcte
                                1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_set_detmovrecibo (
      pnrecibo        IN   NUMBER,
      psmovrec        IN   NUMBER,
      pnorden         IN   NUMBER,
      piimporte       IN   NUMBER,
      pfmovimi        IN   DATE,
      pfefeadm        IN   DATE,
      pcusuari        IN   VARCHAR2,
      psdevolu        IN   NUMBER,
      pnnumnlin       IN   NUMBER,
      pcbancar1       IN   VARCHAR2,
      pnnumord        IN   NUMBER,
      psmovrecr       IN   NUMBER DEFAULT NULL,
      pnordenr        IN   NUMBER DEFAULT NULL,
      ptdescrip       IN   VARCHAR2 DEFAULT NULL,
      piimpmon        IN   NUMBER DEFAULT NULL,
      -- Bug 0026959 - DCG - 14/05/2013
      psproces        IN   NUMBER DEFAULT NULL,
      -- Bug 0026959 - DCG - 14/05/2013
      pimoncon        IN   NUMBER DEFAULT NULL,
      pitasa          IN   NUMBER DEFAULT NULL,
      -- Bug 0026959 - DCG - 30/07/2013
      pfcambio        IN   DATE DEFAULT NULL,
      --pnreccaj IN NUMBER DEFAULT NULL, -- INI IAXIS-4153  /* Cambios de IAXIS-4753 */
      pnreccaj        IN   VARCHAR2 DEFAULT NULL, /*  Cambios de IAXIS-4753 */
      pcmreca         IN   NUMBER DEFAULT NULL,              -- INI IAXIS-4153
      pctipotransap   IN   NUMBER DEFAULT NULL        -- IAXIS-4884 12/09/2019
   )                                         -- Bug 0032674 - MDS - 06/02/2015
      RETURN NUMBER
   IS
      vobjectname       VARCHAR2 (500)
                                   := 'pac_adm_cobparcial.f_set_detmovrecibo';
      vparam            VARCHAR2 (2000)
         :=    'parámetros - smovrec: '
            || psmovrec
            || ' nrecibo:'
            || pnrecibo
            || ' iimporte:'
            || piimporte
            || ' fmovimi:'
            || pfmovimi
            || ' pfefeadm:'
            || pfefeadm
            || ' pcusuari:'
            || pcusuari
            || ' psdevolu:'
            || psdevolu
            || ' pnnumnlin:'
            || pnnumnlin
            || ' pcbancar1:'
            || pcbancar1
            || ' pnnumord:'
            || pnnumord;
      pasexec           NUMBER (5)                        := 1;
      vcount            NUMBER (5);
      vsmovrec          NUMBER                            := psmovrec;
      viimporte         NUMBER                            := piimporte;
      vitotalr          vdetrecibos.itotalr%TYPE;
      -- Bug: 27190 - AFM - 10/06/2013
      vitotalr_monpol   vdetrecibos_monpol.itotalr%TYPE;
      -- Bug: 27190 - AFM - 10/06/2013
      vimpparctot       detmovrecibo.iimporte%TYPE;
      -- Bug: 27190 - AFM - 10/06/2013
      viconcep          detrecibos.iconcep%TYPE;
      -- Bug: 27190 - AFM - 10/06/2013
      viconcep_monpol   detrecibos.iconcep_monpol%TYPE;
      vitotal           detrecibos.iconcep%TYPE;
      vitotal_monpol    detrecibos.iconcep_monpol%TYPE;
      v_pagado          NUMBER                            := 0;
      -- Bug: 27190 - AFM - 10/06/2013
      vcdivisa          productos.cdivisa%TYPE;
      -- Bug: 27190 - AFM - 10/06/2013
      vmoneinst         productos.cdivisa%TYPE;
      -- Bug: 27190 - AFM - 10/06/2013
      vcbancar          VARCHAR2 (50)                     := pcbancar1;
      vfmovimi          DATE                      := NVL (pfmovimi, f_sysdate);
      vnorden           detmovrecibo.norden%TYPE          := pnorden;
      vcusuari          detmovrecibo.cusuari%TYPE    := NVL (pcusuari, f_user);
      --vsdevolu       detmovrecibo.sdevolu%TYPE := NVL(psdevolu, 0);
      --vnnumnlin      detmovrecibo.nnumnlin%TYPE := NVL(pnnumnlin, 0);
      --vnnumord       detmovrecibo.nnumord%TYPE := NVL(pnnumord, 1);
      --vtdescrip      detmovrecibo.tdescrip%TYPE := NVL(ptdescrip, 1);
      vsdevolu          detmovrecibo.sdevolu%TYPE;
      vnnumnlin         detmovrecibo.nnumnlin%TYPE;
      vnnumord          detmovrecibo.nnumord%TYPE;
      vtdescrip         detmovrecibo.tdescrip%TYPE;
      vnerror           NUMBER;                       -- IAXIS-4884 12/09/2019
   BEGIN
      pasexec := 10;                   -- 11 0025611 - Manejo de pagos de ARP

      IF psmovrec IS NULL
      THEN
         SELECT MAX (smovrec)
           INTO vsmovrec
           FROM movrecibo
          WHERE nrecibo = pnrecibo AND cestrec = 0;
      END IF;

      pasexec := 20;                    -- 11 0025611 - Manejo de pagos de ARP

      IF vnorden IS NULL
      THEN
         SELECT MAX (NVL (norden, 0)) + 1
           INTO vnorden
           FROM detmovrecibo
          WHERE nrecibo = pnrecibo AND smovrec = vsmovrec;
      END IF;

      IF vnorden IS NULL
      THEN
         vnorden := 1;
      END IF;

      --S'afegeix ja que sempre ha de grabar un apunt a detmovrecibo i en el cas
      --que sigui null l'import s'agafarà el del rebut.
      pasexec := 30;                    -- 11 0025611 - Manejo de pagos de ARP

      -- ini bug: 27190 AFM - 10/06/2013
      -- Bug 0026959 - DCG - 30/07/2013 - Inici
      IF pimoncon = 1
      THEN
         SELECT itotalr
           INTO vitotalr
           FROM vdetrecibos_monpol
          WHERE nrecibo = pnrecibo;
      ELSE
         SELECT itotalr
           INTO vitotalr
           FROM vdetrecibos
          WHERE nrecibo = pnrecibo;
      END IF;

      -- Bug 0026959 - DCG - 30/07/2013 - Fi
      IF piimporte IS NULL
      THEN
         viimporte := vitotalr;
      END IF;

      -- fin bug: 27190 AFM - 10/06/2013
      IF pcbancar1 IS NULL
      THEN
         pasexec := 40;                -- 11 0025611 - Manejo de pagos de ARP

         BEGIN
            SELECT cbancar
              INTO vcbancar
              FROM recibos
             WHERE nrecibo = pnrecibo;
         EXCEPTION
            WHEN OTHERS
            THEN
               vcbancar := 0;
         END;
      END IF;

      IF vcbancar IS NULL
      THEN
         vcbancar := 0;
      END IF;

      pasexec := 50;                    -- 11 0025611 - Manejo de pagos de ARP

      BEGIN
         -- INI -IAXIS-4153 - JLTS - 07/06/2019
         INSERT INTO detmovrecibo
                     (smovrec, norden, nrecibo, iimporte, fmovimi,
                      fefeadm, cusuari, sdevolu,
                      nnumnlin, cbancar1, nnumord, smovrecr,
                      nordenr, tdescrip, iimporte_moncon, sproces, fcambio,
                      nreccaj, cmreca
                     )
              -- Bug 0026959 - DCG - 14/05/2013; Bug 0032674 - MDS - 06/02/2015
         VALUES      (vsmovrec, vnorden, pnrecibo, viimporte, f_sysdate,
                      pfefeadm, vcusuari, NVL (psdevolu, 0),
                      NVL (pnnumnlin, 0), vcbancar, NVL (pnnumord, 1), NULL,
                      NULL, vtdescrip, piimpmon, psproces, pfcambio,
                      pnreccaj, pcmreca
                     );
             -- Bug 0026959 - DCG - 14/05/2013; Bug 0032674 - MDS - 06/02/2015
      -- FIN -IAXIS-4153 - JLTS - 07/06/2019
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            pasexec := 60;             -- 11 0025611 - Manejo de pagos de ARP

            -- INI -IAXIS-4153 - JLTS - 07/06/2019
            UPDATE detmovrecibo
               SET nrecibo = pnrecibo,
                   iimporte = NVL (viimporte, iimporte),         -- piimporte,
                   fmovimi = vfmovimi,                            -- pfmovimi,
                   fefeadm = NVL (pfefeadm, fefeadm),              -- pfefeadm
                   cusuari = NVL (vcusuari, cusuari),             -- pcusuari,
                   sdevolu = NVL (vsdevolu, sdevolu),             -- psdevolu,
                   nnumnlin = NVL (vnnumnlin, nnumnlin),         -- pnnumnlin,
                   cbancar1 = NVL (vcbancar, cbancar1),          -- pcbancar1,
                   nnumord = NVL (pnnumord, nnumord),              -- pnnumord
                   smovrecr = NVL (psmovrecr, smovrecr),          -- psmovrecr
                   nordenr = NVL (pnordenr, nordenr),             -- pnordenr,
                   tdescrip = NVL (ptdescrip, tdescrip),          -- ptdescrip
                   iimporte_moncon = NVL (piimpmon, iimporte_moncon),
                   -- Bug 0026959 - DCG - 14/05/2013
                   sproces = NVL (psproces, sproces),
                   fcambio = NVL (pfcambio, fcambio),
                   nreccaj = NVL (pnreccaj, nreccaj),        -- INI IAXIS-4153
                   cmreca = NVL (pcmreca, cmreca)            -- INI IAXIS-4153
             -- FIN -IAXIS-4153 - JLTS - 07/06/2019
             -- Bug 0026959 - DCG - 14/05/2013; Bug 0032674 - MDS - 06/02/2015
            WHERE  smovrec = psmovrec AND norden = NVL (pnorden, vnorden);
      -- Bug 0026959 - DCG - 30/07/2013 - Inici
      END;

      pasexec := 70;                    -- 11 0025611 - Manejo de pagos de ARP

      -- ini bug: 27190 AFM - 10/06/2013

      -- Busco divisa del producto
      SELECT cdivisa
        INTO vcdivisa
        FROM productos
       WHERE sproduc IN (SELECT sproduc
                           FROM seguros
                          WHERE sseguro IN (SELECT sseguro
                                              FROM recibos
                                             WHERE nrecibo = pnrecibo));

      pasexec := 80;                    -- 11 0025611 - Manejo de pagos de ARP

      -- Busco divisa Instalación
      SELECT f_parinstalacion_n ('MONEDAINST')
        INTO vmoneinst
        FROM DUAL;

      pasexec := 90;                    -- 11 0025611 - Manejo de pagos de ARP

      -- Busco total pagado
      -- SELECT   SUM(iimporte) -- 11 0025611 - Manejo de pagos de ARP
      SELECT NVL (SUM (iimporte), 0)
        INTO vimpparctot
        FROM detmovrecibo
       WHERE nrecibo = pnrecibo AND norden <= NVL (vnorden, pnorden);

      -- Bug 0026959 - DCG - 30/07/2013 - Inici

      -- GROUP BY nrecibo; -- 11 0025611 - Manejo de pagos de ARP

      -- Busco el total en moneda instalación
      -- 11 0025611 - Manejo de pagos de ARP - Inicio
      --      SELECT itotalr
      --        INTO vitotalr_monpol
      --        FROM vdetrecibos_monpol
      --       WHERE nrecibo = pnrecibo;
      pasexec := 100;

      BEGIN
         SELECT itotalr
           INTO vitotalr_monpol
           FROM vdetrecibos_monpol
          WHERE nrecibo = pnrecibo;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            pasexec := 110;

            SELECT itotalr
              INTO vitotalr_monpol
              FROM vdetrecibos
             WHERE nrecibo = pnrecibo;
      END;

      pasexec := 120;

      -- 11 0025611 - Manejo de pagos de ARP - Final

      -- Selecciona los conceptos excepto el de prima devengada.
      -- INI IAXIS-4153 - JLTS - 17/06/2019. Se eliminan algunos conceptos de la consulta
      FOR i IN (SELECT   *
                    FROM detrecibos
                   WHERE nrecibo = pnrecibo
                     AND cconcep NOT IN
                            (15, 16, 19, 20, 21, 24, 25, 28, 65, 66, 69, 70,
                             71, 74, 75, 78, 11, 32, 33)
                ORDER BY cconcep)
      LOOP
         -- FIN IAXIS-4153 - JLTS - 17/06/2019. Se eliminan algunos conceptos de la consulta
            --
            -- Inicio IAXIS-4884 12/09/2019
            --
         IF pctipotransap = 11
         THEN
            IF i.cconcep IN (0, 50)
            THEN                       -- Conceptos de Primas: local y Cedida
               pasexec := 130;
               vnerror :=
                  f_inserta_detmovrecibo_parcial (pnrecibo,
                                                  i.cconcep,
                                                  i.cgarant,
                                                  i.nriesgo,
                                                  vsmovrec,
                                                  pitasa,
                                                  vmoneinst,
                                                  vitotalr,
                                                  piimporte,
                                                  i.iconcep,
                                                  vcdivisa,
                                                  vimpparctot,
                                                  i.iconcep_monpol,
                                                  piimpmon,
                                                  vnorden,
                                                  pfcambio,
                                                  pnreccaj,
                                                  pcmreca,
                                                  pctipotransap
                                                 );

               IF vnerror <> 0
               THEN
                  RAISE e_object_error;
               END IF;
            END IF;
         ELSIF pctipotransap = 12
         THEN
            IF i.cconcep IN (4, 86)
            THEN                                          -- Conceptos de IVA
               pasexec := 140;
               vnerror :=
                  f_inserta_detmovrecibo_parcial (pnrecibo,
                                                  i.cconcep,
                                                  i.cgarant,
                                                  i.nriesgo,
                                                  vsmovrec,
                                                  pitasa,
                                                  vmoneinst,
                                                  vitotalr,
                                                  piimporte,
                                                  i.iconcep,
                                                  vcdivisa,
                                                  vimpparctot,
                                                  i.iconcep_monpol,
                                                  piimpmon,
                                                  vnorden,
                                                  pfcambio,
                                                  pnreccaj,
                                                  pcmreca,
                                                  pctipotransap
                                                 );

               IF vnerror <> 0
               THEN
                  RAISE e_object_error;
               END IF;
            END IF;
         ELSIF pctipotransap = 13
         THEN
            IF i.cconcep = 14
            THEN                          -- Concepto de Gastos de Expedición
               pasexec := 150;
               vnerror :=
                  f_inserta_detmovrecibo_parcial (pnrecibo,
                                                  i.cconcep,
                                                  i.cgarant,
                                                  i.nriesgo,
                                                  vsmovrec,
                                                  pitasa,
                                                  vmoneinst,
                                                  vitotalr,
                                                  piimporte,
                                                  i.iconcep,
                                                  vcdivisa,
                                                  vimpparctot,
                                                  i.iconcep_monpol,
                                                  piimpmon,
                                                  vnorden,
                                                  pfcambio,
                                                  pnreccaj,
                                                  pcmreca,
                                                  pctipotransap
                                                 );

               IF vnerror <> 0
               THEN
                  RAISE e_object_error;
               END IF;
            END IF;
         ELSE
            /* La siguiente porción de código se ejecutará si no es enviado ningún tipo de transacción desde SAP. Lo que diferencia a esta
               porción de código de la incluida en la función f_inserta_detmovrecibo_parcial, es que la de la función, en lugar de realizar la
               distribución proporcional del valor pagado entre TODOS los conceptos del recibo como se hace a continuación, se distribuye en
               algunos conceptos en particular de acuerdo a la instrucción enviada por SAP (pctipotransap) de la siguiente forma:
                 11 -> Conceptos de Prima (por lo general 0 y 50)
                 12 -> Concepto de IVA (por lo general 4 y 86)
                 13 -> Concepto de Gastos de Expedición (por lo general 14)
             */
            BEGIN
               viconcep := 0;
               viconcep_monpol := 0;

               -- Al ser el último parcial, que completa total de recibo, se hace por diferencia para q cuadre
               IF vimpparctot = vitotalr
               THEN
                  pasexec := 160;      -- 11 0025611 - Manejo de pagos de ARP

                  -- Bug 0025537 - JMF - 08-04-2014
                  SELECT NVL (SUM (NVL (iconcep, 0)), 0)
                    INTO viconcep
                    FROM detmovrecibo_parcial
                   WHERE nrecibo = i.nrecibo
                     AND cconcep = i.cconcep
                     AND cgarant = i.cgarant
                     AND nriesgo = i.nriesgo
                     AND smovrec = vsmovrec;

                  viconcep := i.iconcep - viconcep;

                  --contravalor viconcep pra infor el viconcep_monpol
                  IF pitasa IS NULL
                  THEN
                     viconcep_monpol := viconcep;
                  ELSE
                     viconcep_monpol :=
                           pac_monedas.f_round (viconcep * pitasa, vmoneinst);
                  END IF;

                  --  viconcep_monpol := i.iconcep_monpol - viconcep_monpol;
                  v_pagado := 1;
               ELSE                              -- Se calcula por proporcion.
                  pasexec := 170;      -- 11 0025611 - Manejo de pagos de ARP
                  viconcep :=
                       f_round ((i.iconcep / vitotalr) * piimporte, vcdivisa);
                  --
                  pasexec := 180;      -- 11 0025611 - Manejo de pagos de ARP
                  viconcep_monpol :=
                     f_round ((i.iconcep_monpol / vitotalr_monpol) * piimpmon,
                              vmoneinst
                             );
               --
               END IF;

               --
               IF viconcep <> 0
               THEN
                  pasexec := 190;      -- 11 0025611 - Manejo de pagos de ARP

                  INSERT INTO detmovrecibo_parcial
                              (smovrec, norden, nrecibo, cconcep,
                               cgarant, nriesgo, iconcep,
                               iconcep_monpol, fcambio, nreccaj, cmreca
                              )
                       VALUES (vsmovrec, vnorden, pnrecibo, i.cconcep,
                               i.cgarant, i.nriesgo, viconcep,
                               viconcep_monpol, pfcambio, pnreccaj, pcmreca
                              );
               END IF;
            --
            EXCEPTION
               WHEN OTHERS
               THEN
                  NULL;
            END;

            pasexec := 200;             -- 11 0025611 - Manejo de pagos de ARP
         END IF;
      --
      -- Fin IAXIS-4884 12/09/2019
      --
      END LOOP;

        -- Miramos si el importe pagado corresponde al Sumatorio del desglose de parciales, si no es así incluímos la diferencia a la prima Neta
        -- de la garantía más pequeña.
      --  IF v_pagado = 0 THEN
           --
      SELECT (  SUM (DECODE (cconcep, 0, iconcep, 0))
              + SUM (DECODE (cconcep, 1, iconcep, 0))
              + SUM (DECODE (cconcep, 2, iconcep, 0))
              + SUM (DECODE (cconcep, 3, iconcep, 0))
              + SUM (DECODE (cconcep, 4, iconcep, 0))
              + SUM (DECODE (cconcep, 5, iconcep, 0))
              + SUM (DECODE (cconcep, 6, iconcep, 0))
              + SUM (DECODE (cconcep, 7, iconcep, 0))
              + SUM (DECODE (cconcep, 8, iconcep, 0))
              + SUM (DECODE (cconcep, 14, iconcep, 0))
              - SUM (DECODE (cconcep, 13, iconcep, 0))
              + SUM (DECODE (cconcep, 86, iconcep, 0))
              + SUM (DECODE (cconcep, 26, iconcep, 0))
              + SUM (DECODE (cconcep, 50, iconcep, 0))
              + SUM (DECODE (cconcep, 51, iconcep, 0))
              + SUM (DECODE (cconcep, 52, iconcep, 0))
              + SUM (DECODE (cconcep, 53, iconcep, 0))
              + SUM (DECODE (cconcep, 54, iconcep, 0))
              + SUM (DECODE (cconcep, 55, iconcep, 0))
              + SUM (DECODE (cconcep, 56, iconcep, 0))
              + SUM (DECODE (cconcep, 57, iconcep, 0))
              + SUM (DECODE (cconcep, 58, iconcep, 0))
              + SUM (DECODE (cconcep, 64, iconcep, 0))
              - SUM (DECODE (cconcep, 63, iconcep, 0))
             ),
             (  SUM (DECODE (cconcep, 0, iconcep_monpol, 0))
              + SUM (DECODE (cconcep, 1, iconcep_monpol, 0))
              + SUM (DECODE (cconcep, 2, iconcep_monpol, 0))
              + SUM (DECODE (cconcep, 3, iconcep_monpol, 0))
              + SUM (DECODE (cconcep, 4, iconcep_monpol, 0))
              + SUM (DECODE (cconcep, 5, iconcep_monpol, 0))
              + SUM (DECODE (cconcep, 6, iconcep_monpol, 0))
              + SUM (DECODE (cconcep, 7, iconcep_monpol, 0))
              + SUM (DECODE (cconcep, 8, iconcep_monpol, 0))
              + SUM (DECODE (cconcep, 14, iconcep_monpol, 0))
              - SUM (DECODE (cconcep, 13, iconcep_monpol, 0))
              + SUM (DECODE (cconcep, 86, iconcep_monpol, 0))
              + SUM (DECODE (cconcep, 26, iconcep_monpol, 0))
              + SUM (DECODE (cconcep, 50, iconcep_monpol, 0))
              + SUM (DECODE (cconcep, 51, iconcep_monpol, 0))
              + SUM (DECODE (cconcep, 52, iconcep_monpol, 0))
              + SUM (DECODE (cconcep, 53, iconcep_monpol, 0))
              + SUM (DECODE (cconcep, 54, iconcep_monpol, 0))
              + SUM (DECODE (cconcep, 55, iconcep_monpol, 0))
              + SUM (DECODE (cconcep, 56, iconcep_monpol, 0))
              + SUM (DECODE (cconcep, 57, iconcep_monpol, 0))
              + SUM (DECODE (cconcep, 58, iconcep_monpol, 0))
              + SUM (DECODE (cconcep, 64, iconcep_monpol, 0))
              - SUM (DECODE (cconcep, 63, iconcep_monpol, 0))
             )
        INTO vitotal,
             vitotal_monpol
        FROM detmovrecibo_parcial
       WHERE nrecibo = pnrecibo AND norden = vnorden AND smovrec = vsmovrec;

      --
      IF vitotal_monpol <> piimpmon
      THEN
         vitotal_monpol := piimpmon - vitotal_monpol;

         --
         UPDATE detmovrecibo_parcial
            SET iconcep_monpol = iconcep_monpol + vitotal_monpol
          WHERE nrecibo = pnrecibo
            AND norden = vnorden
            AND smovrec = vsmovrec
            -- Inicio IAXIS-4884 12/09/2019
            -- Lo mandamos al concepto según transacción SAP
            --AND cconcep = 0
            AND cconcep = DECODE (pctipotransap, 11, 0, 12, 4, 14, 0)
            -- Fin IAXIS-4884 12/09/2019
            AND cgarant =
                   (SELECT MIN (cgarant)
                      FROM detmovrecibo_parcial
                     WHERE nrecibo = pnrecibo
                       AND norden = vnorden
                       AND smovrec = vsmovrec
                       -- Inicio IAXIS-4884 12/09/2019
                       -- Lo mandamos al concepto según transacción SAP
                       --AND cconcep = 0
                       AND cconcep =
                                   DECODE (pctipotransap,
                                           11, 0,
                                           12, 4,
                                           14, 0
                                          ));
      -- Fin IAXIS-4884 12/09/2019
      END IF;

      --
      IF vitotal <> piimporte
      THEN
         vitotal := piimporte - vitotal;

         --
         UPDATE detmovrecibo_parcial
            SET iconcep = iconcep + vitotal
          WHERE nrecibo = pnrecibo
            AND norden = vnorden
            AND smovrec = vsmovrec
            -- Inicio IAXIS-4884 12/09/2019
            -- Lo mandamos al concepto según transacción SAP
            --AND cconcep = 0
            AND cconcep = DECODE (pctipotransap, 11, 0, 12, 4, 14, 0)
            -- Fin IAXIS-4884 12/09/2019
            AND cgarant =
                   (SELECT MIN (cgarant)
                      FROM detmovrecibo_parcial
                     WHERE nrecibo = pnrecibo
                       AND norden = vnorden
                       AND smovrec = vsmovrec
                       -- Inicio IAXIS-4884 12/09/2019
                       -- Lo mandamos al concepto según transacción SAP
                       --AND cconcep = 0
                       AND cconcep =
                                   DECODE (pctipotransap,
                                           11, 0,
                                           12, 4,
                                           14, 0
                                          ));
      -- Fin IAXIS-4884 12/09/2019
      END IF;

       --
      -- END IF;

      -- fin bug: 27190 AFM - 10/06/2013
      pasexec := 210;                   -- 11 0025611 - Manejo de pagos de ARP
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      pasexec,
                      vparam,
                      'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 9904219;
--Error al actualizar tabla DETMOVRECIBO.
   END f_set_detmovrecibo;

   /*************************************************************************
    FUNCTION f_anula_rec
      Acciones a realizar para la anulación de los recibos que tienen cobros parciales.

      PARAMETROS:

        PNRECIBO   NUMBER    Número de recibo.
        PFANULAC   DATE      Fecha anulación
        PSMOVAGR   NUMBER    Código de secuencia movimientos de recibos agrupados
        PNO_ANUL   NUMBER    Si es un 1 no se anula la póliza

           return             : 0 -> Tot correcte
                                1 -> S'ha produit un error

      -- Los recibos con cobros parciales no se pueden anular.
      -- La gestión consiste en generar un último pago parcial por el importe
      -- pendiente de cobro, y un recibo de extorno del mismo importe.
      -- Tanto el recibo que se iba a anular como el de extorno quedarán
      -- en estado pendiente a la espera de confirmación contable.

      -- La fecha de anulación inicialmente no está pensada para utilizarse como
      -- parámetro de entrada, porque la acción a realizar será siempre la
      -- misma, por ejemplo si la fecha de anulación no coincidiera con el periodo
      -- cubierto por los pagos parciales, el posible extorno de parte de esas primas
      -- parciales seria intratable.
      -- Pero sí de salida, pues se informaría la fecha hasta la que cubririan los
      -- cobros parciales, para después poder utilizarla para la anulación de póliza.
   *************************************************************************/
   FUNCTION f_anula_rec (
      pnrecibo   IN       NUMBER,
      pfanulac   IN       DATE,
      psmovagr   IN OUT   NUMBER,
      pno_anul   IN       NUMBER DEFAULT 0
   )
      RETURN NUMBER
   IS
      vobject          VARCHAR2 (500)     := 'pac_adm_cobparcial.f_anula_rec';
      vparam           VARCHAR2 (2000)
         :=    'parámetros - nrecibo:'
            || pnrecibo
            || ' pfanulac:'
            || pfanulac
            || ' psmovagr:'
            || psmovagr;
      vpasexec         NUMBER (5)                  := 1;
      viimporte        NUMBER;
      verror           NUMBER                      := 0;
      vipdtecob        NUMBER                      := 0;
      vigenera         NUMBER                      := 0;
      vsseguro         recibos.sseguro%TYPE;
      vfefecto         recibos.fefecto%TYPE;
      vfvencim         recibos.fvencim%TYPE;
      vcagente         recibos.cagente%TYPE;
      vccobban         recibos.ccobban%TYPE;
      vnmovimi         recibos.nmovimi%TYPE;
      vnriesgo         recibos.nriesgo%TYPE;
      vnrecibo         recibos.nrecibo%TYPE;
      vcempres         seguros.cempres%TYPE;
      vsproduc         productos.sproduc%TYPE;
      vmoneprod        productos.cdivisa%TYPE;
      vmoneempr        parempresas.nvalpar%TYPE;
      vitasa           eco_tipocambio.itasa%TYPE;
      lhayctacliente   parempresas.nvalpar%TYPE;
      vimporte_out     NUMBER;
      vmodcom          NUMBER;
      vfcobros         DATE;
      vmensajes        t_iax_mensajes;
   BEGIN
      vpasexec := 10;

      IF pnrecibo IS NULL
      THEN
         RAISE e_param_error;
      ELSE
         vpasexec := 20;

-- INI AFM - 33921 - CAMBIADO DE SITIO ESTABA DESPUES DE LA LLAMADA AL F_COBRO_PARCIAL, CAMBIO PARA PASAR MONEDA
         SELECT r.sseguro, r.fefecto, r.fvencim, r.cagente, r.ccobban,
                r.nmovimi, r.nriesgo, s.cempres, p.cdivisa, p.sproduc
           INTO vsseguro, vfefecto, vfvencim, vcagente, vccobban,
                vnmovimi, vnriesgo, vcempres, vmoneprod, vsproduc
           FROM recibos r, seguros s, productos p
          WHERE r.nrecibo = pnrecibo
            AND r.sseguro = s.sseguro
            AND p.sproduc = s.sproduc;

-- FIN AFM
         -- Genera un importe parcial por el resto de importe pendiente
         -- Si 3er parametro es nulo la función calcula el importe pendiente de pago,
         -- genera el pago por ese importe que retorna en el último parámetro (vigenera).
-- INI AFM  - 33921 - AÑADO PARAMETRO VMONEPROD
         verror :=
            pac_adm_cobparcial.f_cobro_parcial_recibo (pnrecibo,
                                                       NULL,
                                                       NULL,
                                                       vmoneprod,
                                                       vigenera,
                                                       vfcobros
                                                      );

-- FIN AFM

         -- Bug 0026959 - DCG - 14/05/2013 - Fi
         IF verror != 0
         THEN
            RAISE e_object_error;
         END IF;

         vpasexec := 30;
         -- Crear nuevo recibo de extorno por el importe de pago parcial generado
         verror :=
            f_genera_recibo (vcempres,
                             vsseguro,
                             pnrecibo,
                             vfefecto,
                             vfvencim,
                             NULL,
                             vnmovimi,
                             NULL,
                             vmoneprod,
                             vnrecibo,
                             9,
                             1,
                             NULL,
                             0
                            );
/*
-- 33921
         vpasexec := 40;
         verror := f_insrecibo(vsseguro, vcagente, f_sysdate, vfefecto, vfvencim, 9, NULL,
                               NULL, vccobban, 0, vnriesgo, vnrecibo, 'A', NULL, 51, vnmovimi,
                               f_sysdate);

         IF verror != 0 THEN
            RAISE e_object_error;
         END IF;

         IF f_es_renovacion(vsseguro) = 0 THEN   -- es cartera
            vmodcom := 2;
         ELSE   -- si es 1 es nueva produccion
            vmodcom := 1;
         END IF;

-- Bug 0026959 - DCG - 14/05/2013 -Ini
-- El importe que nos devuelve el vigenera es el importe en la moneda del producto, comentamos las siguientes acciones por no ser necesarias.
--         -- Inicio 6.0 - 26301
--         -- Tenemos que mirar en que moneda nos ha devuelto el vigenera, siempre es la de la instalación/empresa, por lo que hay que
--         -- mirar antes de generar el detalle del recibo, que el importe sea en la moneda del producto.
--         vmoneempr := NVL(pac_parametros.f_parempresa_n(vcempres, 'MONEDA_POL'), 0);
--
--         IF vmoneempr <> vmoneprod THEN
--            vitasa := pac_eco_tipocambio.f_cambio(pac_monedas.f_cmoneda_t(vmoneprod),
--                                                  pac_monedas.f_cmoneda_t(vmoneempr),
--                                                  f_sysdate);

         --            IF vitasa IS NULL THEN
--               RETURN 9902592;
--            -- No se ha encontrado el tipo de cambio entre monedas
--            END IF;

         --            --
--            vigenera := pac_monedas.f_round(vigenera * vitasa, vmoneprod);
--         --
--         END IF;
-- Bug 0026959 - DCG - 14/05/2013 .Fi

         -- Fin 6.0 - 26301
         vpasexec := 50;
         verror := f_detrecibo(NULL, vsseguro, vnrecibo, NULL, 'A', vmodcom, f_sysdate,
                               vfefecto, NULL, NULL, vigenera, NULL, vnmovimi, NULL,
                               vimporte_out);

         IF verror != 0 THEN
            RAISE e_object_error;
         END IF;
*/
         vpasexec := 60;

         UPDATE recibos
            SET cestimp = 0,                         --> No se imprime --> JDE
                cbancar = NULL
          WHERE nrecibo = vnrecibo;

         -- 16.0 - 24-12-2013 - MMM - 0029431: LCOL_MILL-10603: Al reactivar una poliza, el sistema debe conservar... Inicio
         -- Actualizamos el cmotmov a 339
         UPDATE movrecibo
            SET cmotmov = 339
          WHERE nrecibo = vnrecibo;

-- INI AFM  - 33921 - SI CTACLIENTE = 1 DAR COBRADO EL RECIBO DE EXTORNO QUE HA GENERADO ---> VNRECIBO.
         lhayctacliente :=
                         NVL (f_parproductos_v (vsproduc, 'HAYCTACLIENTE'), 0);

         IF lhayctacliente = 1
         THEN
                  --pctipcob ponemos 10 compensado
            -- INI -IAXIS-4153 - JLTS - 07/06/2019
            verror :=
               pac_md_con.f_cobrar_recibo (vnrecibo,
                                           10,
                                           NULL,
                                           NULL,
                                           vmensajes
                                          );
         -- FIN -IAXIS-4153 - JLTS - 07/06/2019
         END IF;
-- FIN AFM SI CTACLIENTE = 1 DAR COBRADO EL RECIBO DE EXTORNO QUE HA GENERADO ---> VNRECIBO.

      -- 16.0 - 24-12-2013 - MMM - 0029431: LCOL_MILL-10603: Al reactivar una poliza, el sistema debe conservar... Fin

      -- JAMF 33921  23/01/2015   No se ha de anular nunca la póliza automáticamente al anular un recibo
--         IF pno_anul = 0 THEN
--            -- La anulación de un recibo parcial ha de generar la anulación de la póliza.
--            -- 339 Anulación de póliza con pagos parciales
--            pac_devolu.anula_poliza(vsseguro, vfcobros, 339);
--         END IF;
      END IF;

      RETURN verror;
   EXCEPTION
      WHEN e_object_error
      THEN
         p_tab_error (f_sysdate, f_user, vobject, vpasexec, vparam, verror);
         RETURN verror;
      WHEN e_param_error
      THEN
         verror := 1000005;
         p_tab_error (f_sysdate, f_user, vobject, vpasexec, vparam, verror);
         RETURN verror;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN SQLCODE;
   END f_anula_rec;

   -- 14.0 0028577#c156387 - Inicio
   FUNCTION f_agd_observaciones (
      pcempres   IN   NUMBER,
      pnrecibo   IN   NUMBER,
      ptextobs   IN   VARCHAR2
   )
      RETURN NUMBER
   IS
      vidobs        agd_observaciones.idobs%TYPE;
      num_err       NUMBER;
      vpasexec      NUMBER;
      vobjectname   VARCHAR2 (500)
                                  := 'PAC_ADM_COBPARCIAL.f_agd_observaciones';
      vparam        VARCHAR2 (1000)
         :=    'parámetros - pcempres: '
            || pcempres
            || ' pnrecibo:'
            || pnrecibo
            || ' ptextobs:'
            || ptextobs;
   BEGIN
      vpasexec := 10;

      BEGIN
         SELECT NVL (MAX (idobs), 0) + 1
           INTO vidobs
           FROM agd_observaciones
          WHERE cempres = pcempres;
      EXCEPTION
         WHEN OTHERS
         THEN
            vidobs := 1;
      END;

      vpasexec := 20;
      -- 9906172 - Cobro Parcial
      num_err :=
         pac_agenda.f_set_obs
                             (pcempres,
                              vidobs,
                              1,
                              0,
                              f_axis_literales (9906172,
                                                pac_md_common.f_get_cxtidioma
                                               ),
                              ptextobs,
                              f_sysdate,
                              NULL,
                              2,
                              NULL,
                              NULL,
                              NULL,
                              1,
                              1,
                              f_sysdate,
                              vidobs
                             );

      IF num_err <> 0
      THEN
         RETURN num_err;
      END IF;

      vpasexec := 30;

      UPDATE agd_observaciones
         SET nrecibo = pnrecibo
       WHERE cempres = pcempres AND idobs = vidobs;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 806310;
   END f_agd_observaciones;

   -- 14.0 0028577#c156387 - Final

   /*******************************************************************************
   FUNCION PAC_ADM_COBPARCIAL.F_COBRO_PARCIAL_RECIBO
   Registra los cobros parciales de los recibos.
   Sí los cobros parciales igualan el total del recibo este se dará por cobrado.
   Sí los cobros parciales superan el total del recibo dará un error.

   Parámetros:
     param in pnrecibo  : Número de recibo
     param in pctipcob  : Tipo de cobro (V.F.: 552)
     param in piparcial : Importe del cobro parcial (*)
     param in pcmoneda  : Código de moneda (inicialmente no se tiene en cuenta)
     param out pigenera : Importe del pago generado finalmente (normalmente coincidirá con el piparcial)
     param out pfcobrado: Fecha que cubriría el periodo cobrado
     param in pnocobrar : Cuando es 0 y se complete el importe total del recibo se cobrará el recibo, 1 NO

     return: number un número con el id del error, en caso de que todo vaya OK, retornará un cero.

     (*) Si el pago parcial viene a nulo se generará el pago por el resto del importe pendiente de cobro
     Esta funcionalidad se penso para ahorrar pasos en la anulación de los recibo parciales (f_anula_rec).
   ********************************************************************************/
   FUNCTION f_cobro_parcial_recibo (
      --
      -- Inicio IAXIS-7640 04/12/2019
      --
      --pnrecibo IN NUMBER,
      pnrecibo        IN       VARCHAR2,
      --
      -- Fin IAXIS-7640 04/12/2019
      --
      pctipcob        IN       NUMBER,
      piparcial       IN       NUMBER,
      pcmoneda        IN       NUMBER,
      pigenera        OUT      NUMBER,
      pfcobrado       OUT      DATE,
      pnocobrar       IN       NUMBER DEFAULT 0,      -- 3.0 0022346 - 0127366
      -- Bug 0026959 - DCG - 14/05/2013 - Inici
      -- 12.0  18/09/2013  JGR      0028206: LCOL_PROD-Revision de mensajes en TxNoPago y otros package - Inicio
      -- psproces IN NUMBER,
      -- pfcobparc IN DATE
      psproces        IN       NUMBER DEFAULT NULL,
      pfcobparc       IN       DATE DEFAULT NULL,
      -- 12.0  18/09/2013  JGR      0028206: LCOL_PROD-Revision de mensajes en TxNoPago y otros package - Final
                       -- Bug 0026959 - DCG - 14/05/2013 - Fi
      pnrecsap        IN       VARCHAR2 DEFAULT NULL,  -- 14.0 0028577#c156387
      pcususap        IN       VARCHAR2 DEFAULT NULL,  -- 14.0 0028577#c156387
      -- INI -IAXIS-4153 - JLTS 07/06/2019 Se adicionan los campos cmreca y nreccaj,
      pnreccaj        IN       VARCHAR2 DEFAULT NULL,
      /* Cambios de IAXIS-4753 */
      pcmreca         IN       NUMBER DEFAULT NULL,
      pcindicaf       IN       VARCHAR2 DEFAULT NULL,   ------Changes for 4944
      pcsucursal      IN       VARCHAR2 DEFAULT NULL,   ------Changes for 4944
      pndocsap        IN       VARCHAR2 DEFAULT NULL,
      pctipotransap   IN       NUMBER DEFAULT NULL    -- IAXIS-4884 12/09/2019
   )
      -- FIN -IAXIS-4153 - JLTS 07/06/2019
   RETURN NUMBER
   IS
      -- OSUAREZ CONFCC-7 INI
      CURSOR cur_per_rel (pnrecibo IN NUMBER)
      IS
         SELECT p.sperson sperson, UPPER (p.nnumide) nnumide,
                pdp.tnombre tnombre, p.ctipide ctipide, p.ctipper ctipper
           FROM per_personas p, per_detper pdp, tomadores t, recibos r
          WHERE t.sseguro = r.sseguro
            AND p.sperson = t.sperson
            AND p.sperson = pdp.sperson
            AND r.nrecibo = pnrecibo
         UNION
         SELECT p.sperson, UPPER (p.nnumide), pdp.tnombre, p.ctipide,
                p.ctipper
           FROM per_personas p, per_detper pdp, asegurados a, recibos r
          WHERE a.sseguro = r.sseguro
            AND p.sperson = a.sperson
            AND p.sperson = pdp.sperson
            AND r.nrecibo = pnrecibo
         UNION
         SELECT p.sperson, UPPER (p.nnumide), pdp.tnombre, p.ctipide,
                p.ctipper
           FROM per_personas p, per_detper pdp, benespseg b, recibos r
          WHERE b.sseguro = r.sseguro
            AND p.sperson = b.sperson
            AND p.sperson = pdp.sperson
            AND r.nrecibo = pnrecibo;

      -- OSUAREZ CONFCC-7 FIN
      vobject            VARCHAR2 (500)
                                := 'pac_adm_cobparcial.f_cobro_parcial_recibo';
      vpasexec           NUMBER (8)                    := 1;
      vparam             VARCHAR2 (2000)
         :=    'pnrecibo:'
            || pnrecibo
            || ', pctipcob:'
            || pctipcob
            || ' piparcial:'
            || piparcial
            || ', pcmoneda:'
            || pcmoneda;
      verror             NUMBER                        := 0;
      -- vcempres       recibos.cempres%TYPE;
      vcempres           recibos.cempres%TYPE
                                             := pac_md_common.f_get_cxtempresa;
      -- 14.0 0028577#c156387
      vcdelega           recibos.cdelega%TYPE;
      vccobban           recibos.ccobban%TYPE;
      vfefecto           recibos.fefecto%TYPE;
      vfvencim           recibos.fvencim%TYPE;
      vctipcob           seguros.ctipcob%TYPE;
      --vcmoneda       seguros.cmoneda%TYPE; --IAXIS.4153: Se comentariza la variable
      vfmovini           movrecibo.fmovini%TYPE;
      vsmovrec           movrecibo.smovrec%TYPE;
      vitotalr           vdetrecibos.itotalr%TYPE;
      -- INI IAXIS-4153 - JLTS - 17/06/2019. Se incluyeny ajustan algunas variables
      vitotalr_aux       vdetrecibos.itotalr%TYPE;
      viimporte_aux      detmovrecibo.iimporte%TYPE;
      viacumula_aux      detmovrecibo.iimporte%TYPE;
      -- FIN IAXIS-4153 - JLTS - 17/06/2019. Se incluyeny ajustan algunas variables
      vtdescrip          detmovrecibo.tdescrip%TYPE;
      vcidioma           NUMBER               := pac_md_common.f_get_cxtidioma;
      vporcen            NUMBER;
      vdiascobra         NUMBER;
      viparcial          NUMBER;
-- IAXIS-4153 - JLTS - 17/06/2019. Se elimina la inicialización de la variable (piparcial)
      vmensajes          t_iax_mensajes;
      -- Bug 0026959 - DCG - 14/05/2013 - Inici
      vitotalr_monpol    vdetrecibos.itotalr%TYPE;
      vmoneprod          productos.cdivisa%TYPE;
      vn_moneinst        productos.cdivisa%TYPE;
      viparcial_moncon   NUMBER                        := piparcial;
      -- IAXIS-4153 - JLTS - 17/06/2019. Se inicializa la variable con piparcial
      vitasa             eco_tipocambio.itasa%TYPE;
      vfcambio           DATE;
      -- Bug 0026959 - DCG - 14/05/2013 - Fi
         -- Bug 0026959 - DCG - 30/07/2013 - Inici
      vimoncon           NUMBER;
      -- Bug 0026959 - DCG - 30/07/2013 - Fi
      vtextobs           agd_observaciones.tobs%TYPE;  -- 14.0 0028577#c156387
      vctipban           recibos.ctipban%TYPE;
      vcbancar           recibos.cbancar%TYPE;
      vcestrecat         NUMBER;
      vpermitedoble      NUMBER;
      vsinterf           NUMBER;
      vterror            VARCHAR2 (2000);
      -- INI IAXIS-4153 - JLTS - 17/06/2019. Se adicionan variables
      vcmultimon         NUMBER                        := 0;
      vfemisio           DATE                          := NULL;
      vfcambioo          DATE                          := NULL;
      v_cagente          NUMBER;
      v_city             VARCHAR2 (1000);               ------Changes for 4944
      -- FIN IAXIS-4153 - JLTS - 17/06/2019.
      --
      -- Inicio IAXIS-4884 12/09/2019
      --
      sql_stmt           VARCHAR2 (500);               -- Sentencia principal.
      sqlandcon          VARCHAR2 (100);
      -- Condición AND según transacción SAP
      visalcon           NUMBER;                        -- Saldo de conceptos.
      vipagcon           NUMBER;            -- Importe pagado a los conceptos.
      vitotcon           NUMBER;             -- Importe total de los conceptos
      --
      -- Fin IAXIS-4884 12/09/2019
      --
      vnrecibo           NUMBER;                       --IAXIS-7640 04/12/2019
   --
   BEGIN
      -- INI IAXIS-4153 - JLTS - 17/06/2019. Adición de la consulta de la moneda de la instalación
      SELECT f_parinstalacion_n ('MONEDAINST')
        INTO vn_moneinst
        FROM DUAL;

      IF pcmoneda != vn_moneinst
      THEN
         IF pcmoneda IS NOT NULL
         THEN
            verror := 2000096;
         -- Todo pago debe venir en pesos f_parinstalacion_n('MONEDAINST')
         END IF;

         RAISE e_object_error;
      END IF;

      -- FIN IAXIS-4153 - JLTS - 17/06/2019.
      IF pnrecibo IS NULL
      THEN
           -- 6.0  se suprime modif. 5.0, si vienen pagos a null tienen que tratarse. Haciendo pruebas vi error -Inicio
           -- 5.0  0026022 - 013954 - Inicio
         --  OR piparcial IS NULL THEN
         vpasexec := 10;
         RAISE e_param_error;
      -- ELSIF piparcial > 0 THEN
      ELSE
         --
         -- Inicio IAXIS-7640 04/12/2019
         --
         -- Para eventos en los que la póliza sea migrada, SAP enviará el número de documento de Osiris en lugar de un número de recibo de iAxis.
         -- Dado lo anterior, se buscará primero la correspondencia en iAxis entre el número de documento de Osiris y el número de recibo de iAxis
         -- en la tabla de recibos.
         BEGIN
            --
            SELECT r.nrecibo
              INTO vnrecibo
              FROM recibos r
             WHERE r.creccia = pnrecibo;
         --
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               -- Si no se encuentra correspondencia, se entenderá que se envía un directamente un número de recibo de iAxis.
               vnrecibo := pnrecibo;
         --
         END;

         --
         -- Fin IAXIS-7640 04/12/2019
         --
         -- 6.0  Fin
         -- 5.0  0026022 - 013954 - Fin
         -- 2.0  002234 - 0127248 - Inicio
         BEGIN
            vpasexec := 20;

                  -- Bug 0026959 - DCG - 14/05/2013 - Ini
            -- INI IAXIS-4153 - JLTS - 17/06/2019. Se ajusta la consulta
            SELECT NVL (pctipcob, s.ctipcob), d.itotalr,
                   v.itotalr itotalr_monpol, m.smovrec, r.fefecto,
                   r.fvencim, p.cdivisa, m.fmovini, r.ctipban, r.cbancar,
                   r.ccobban, r.cdelega, m.cestrec,
                   s.cagente                            ------changes for 4944
              INTO vctipcob, vitotalr,
                   vitotalr_monpol, vsmovrec, vfefecto,
                   vfvencim, vmoneprod, vfmovini, vctipban, vcbancar,
                   vccobban, vcdelega, vcestrecat,
                   v_cagente
              FROM recibos r,
                   seguros s,
                   vdetrecibos_monpol v,
                   movrecibo m,
                   vdetrecibos d,
                   productos p
             WHERE r.nrecibo = vnrecibo               -- IAXIS-7640 04/12/2019
               AND d.nrecibo = vnrecibo               -- IAXIS-7640 04/12/2019
               -- Bug 0026959 - DCG - 14/05/2013 - Fi
               AND v.nrecibo = vnrecibo               -- IAXIS-7640 04/12/2019
               AND m.nrecibo = vnrecibo               -- IAXIS-7640 04/12/2019
               AND m.fmovfin IS NULL
               AND r.sseguro = s.sseguro
               AND s.sproduc = p.sproduc;

             -- FIN IAXIS-4153 - JLTS - 17/06/2019.
            ------changes for 4944 started
            BEGIN
               SELECT f_desagente_t (pac_agentes.f_get_cageliq (24,
                                                                pcsucursal,
                                                                v_cagente
                                                               )
                                    ) sucursal
                 INTO v_city
                 FROM DUAL;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  v_city := NULL;
            END;
         ------changes for 4944 Ended
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               -- 2.0  002234 - 0127248 - Fin
               BEGIN
                  vpasexec := 30;

                  -- INI IAXIS-4153 - JLTS - 17/06/2019. Se adiciona variable r.femisio
                  SELECT NVL (pctipcob, s.ctipcob), v.itotalr,
                         NULL itotalr_monpol, m.smovrec, r.fefecto,
                         r.fvencim, p.cdivisa, m.fmovini, r.ctipban,
                         r.cbancar, r.ccobban, r.cdelega, m.cestrec,
                         r.femisio
                    INTO vctipcob, vitotalr,
                         vitotalr_monpol, vsmovrec, vfefecto,
                         vfvencim, vmoneprod, vfmovini, vctipban,
                         vcbancar, vccobban, vcdelega, vcestrecat,
                         vfemisio
                    FROM recibos r,
                         seguros s,
                         vdetrecibos v,
                         movrecibo m,
                         productos p
                   WHERE r.nrecibo = vnrecibo         -- IAXIS-7640 04/12/2019
                     AND v.nrecibo = vnrecibo         -- IAXIS-7640 04/12/2019
                     AND m.nrecibo = vnrecibo         -- IAXIS-7640 04/12/2019
                     AND m.fmovfin IS NULL
                     AND r.sseguro = s.sseguro
                     AND s.sproduc = p.sproduc;
               -- FIN IAXIS-4153 - JLTS - 17/06/2019.
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     -- Error en datos enviados
                     verror := 9001250;
                     --RAISE e_object_error;
                     -- Por el listener de cobro de recibos nos llegan masivamente muchos cobros de recibos
                     -- que no existen en iAXIS. Para evitar tanta escritura en TAB_ERROR obviamos el RAISE y retornamos.
                     RETURN verror;
               END;
         END;

         -- 2.0  002234 - 0127248 - Fin
         -- OSUAREZ CONFCC-7 INI
         /*  INI --IAXIS-5096 - JLT - 21/08/2019 - Se elimina ( comentariza) este llamado */
         /*
         FOR R_C1 IN CUR_PER_REL(pnrecibo) LOOP
            verror := pac_listarestringida.f_consultar_compliance(R_C1.sperson, R_C1.nnumide, R_C1.tnombre, R_C1.ctipide, R_C1.ctipper);
         END LOOP;
         -- OSUAREZ CONFCC-7 FIN
         /*  FIN --IAXIS-5096 - JLT - 21/08/2019 - Se elimina ( comentariza) este llamado */
         vpasexec := 40;
         vpermitedoble :=
            NVL (pac_parametros.f_parempresa_n (vcempres,
                                                'PERMITE_DOBL_RECAUDO'
                                               ),
                 0
                );
         vpasexec := 45;
         -- INI IAXIS-4153 - JLTS - 17/06/2019. Se adiciona condición
         vcmultimon :=
              NVL (pac_parametros.f_parempresa_n (vcempres, 'MULTIMONEDA'), 0);

         IF vcmultimon = 1
         THEN
            SELECT NVL (MAX (fcambio), vfemisio)
              INTO vfcambio
              FROM detrecibos
             WHERE nrecibo = vnrecibo;                -- IAXIS-7640 04/12/2019

            verror :=
               pac_oper_monedas.f_datos_contraval (NULL,
                                                   vnrecibo,
                                                   NULL,
                                                   vfcambio,
                                                   1, -- IAXIS-7640 04/12/2019
                                                   vitasa,
                                                   vfcambioo
                                                  );

            IF verror <> 0
            THEN
               RETURN verror;
            END IF;
         END IF;

         -- INI IAXIS-4518 - JLTS -18/07/2019 - Ajuste de redondeos
         viparcial := f_round (viparcial_moncon / vitasa, vmoneprod);

          -- FIN IAXIS-4518 - JLTS -18/07/2019 - Ajuste de redondeos
         -- FIN IAXIS-4153 - JLTS - 17/06/2019. Se adiciona condición
         IF    (vmoneprod = vn_moneinst
               )     -- IAXIS-4153 - JLTS - 17/06/2019. Se ajusta la condición
            OR (pcmoneda IS NULL)
         THEN
            vpasexec := 50;
            vimoncon := 1;
         ELSE
            vimoncon := 0;
         END IF;

         vpasexec := 55;

         IF NOT (vcestrecat = 1 AND vpermitedoble = 1)
         THEN
            -- Bug 0026959 - DCG - 30/07/2013 - Fi

            -- Importes parciales anteriores
            vpasexec := 60;
            -- INI IAXIS-4518 - JLTS -18/07/2019 - Ajuste de redondeos
            viimporte_aux :=
               pac_adm_cobparcial.f_get_importe_cobro_parcial (vnrecibo,
                                                               NULL,
                                                               NULL,
                                                               vimoncon
                                                              );
                                                      -- IAXIS-7640 04/12/2019
            -- FIN IAXIS-4518 - JLTS -18/07/2019 - Ajuste de redondeos
                 -- Bug 0026959 - DCG - 30/07/2013
            vpasexec := 70;

            -- INI -IAXIS-4153 -JLTS -17/06/2019 Se inserta condición para evaluar el valor parcial según moneda
            IF vimoncon = 0
            THEN
               -- Es moneda extranjera
               viacumula_aux := viimporte_aux + viparcial;
               -- INI IAXIS-4518 - JLTS -18/07/2019 - Ajuste de redondeos
               vitotalr_aux := vitotalr;
            -- FIN IAXIS-4518 - JLTS -18/07/2019 - Ajuste de redondeos
            ELSE
               viacumula_aux := viimporte_aux + NVL (viparcial_moncon, 0);
               vitotalr_aux := vitotalr_monpol;
            END IF;

            -- FIN -IAXIS-4153 -JLTS -17/06/2019.
            -- INI IAXIS-4153 - JLTS - 17/06/2019. Se ajusta la variable vitotalr por vitotalr_aux
            -- Calculamos los días que cubren los cobros parciales
            IF vitotalr_aux != 0
            THEN
               vpasexec := 80;
               vdiascobra :=
                         (vfvencim - vfefecto) / vitotalr_aux * viacumula_aux;
               vpasexec := 90;
               pfcobrado := vfefecto + vdiascobra;
            ELSE
               vpasexec := 100;
               pfcobrado := NULL;
            END IF;

            --
            -- Inicio IAXIS-4884 12/09/2019
            -- Seleccionamos el AND indicado según la transacción de SAP
            --
            IF pctipotransap = 11
            THEN
               sqlandcon := ' AND d.cconcep IN (0,50)';
            ELSIF pctipotransap = 12
            THEN
               sqlandcon := ' AND d.cconcep IN (4,86)';
            ELSE
               sqlandcon := ' AND d.cconcep = 14';
            END IF;

            --
            -- Sentencia para extraer el importe total de los conceptos a recaudar según transacción SAP.
            -- Se debe hacer dinámico para permitir filtrar los conceptos según la transacción SAP.
            sql_stmt :=
                  'SELECT NVL(SUM(d.iconcep_monpol),0)'
               || ' FROM detrecibos d '
               || 'WHERE d.nrecibo ='
               || vnrecibo;                           -- IAXIS-7640 04/12/2019
            --
            sql_stmt := sql_stmt || sqlandcon;

            --
            EXECUTE IMMEDIATE sql_stmt
                         INTO vitotcon;

            --
            -- Sentencia para extraer los importes recaudados a los conceptos según transacción SAP.
            -- Dinámica por la misma razón que la anterior.
            --
            sql_stmt :=
                  'SELECT NVL(SUM(d.iconcep_monpol),0)'
               || ' FROM detmovrecibo_parcial d '
               || 'WHERE d.nrecibo = '
               || vnrecibo                            -- IAXIS-7640 04/12/2019
               || '  AND d.smovrec = (SELECT MAX(d1.smovrec) FROM detmovrecibo_parcial d1 WHERE d.nrecibo = d1.nrecibo)';
                                                      -- IAXIS-4926 23/10/2019
            --
            sql_stmt := sql_stmt || sqlandcon;

            --
            EXECUTE IMMEDIATE sql_stmt
                         INTO vipagcon;

            --
            visalcon := vitotcon - vipagcon;

            -- Si el pago parcial a aplicar según los conceptos (prima, gastos, IVA) es mayor al saldo o al total
            -- del importe de dichos conceptos se lanza el error: "Pago excede el saldo del concepto".
            IF piparcial > visalcon OR piparcial > vitotcon
            THEN
               verror := 89907056;
               RAISE e_object_error;
            END IF;

            --
            -- Fin IAXIS-4884 12/09/2019
            --

            -- INI IAXIS-4518 - JLTS -18/07/2019 - Ajuste de redondeos
            IF ROUND (viacumula_aux) > ROUND (vitotalr_aux)
            THEN
               -- FIN IAXIS-4518 - JLTS -18/07/2019 - Ajuste de redondeos
                       -- Suma de importes parciales más grande que el importe del recibo
               verror := 9002147;
               RAISE e_object_error;
            -- 5.0  0026022 - 0139541 - Inicio
            ELSIF     viparcial_moncon = vitotalr_monpol
                  AND NVL (viimporte_aux, 0) = 0
                  AND vitotalr_monpol != 0
            THEN
               -- Cuando el primer pago parcial es igual al importe del recibo
               -- este se cobra pero no generamos apunte de pago parcial.
                --IGIL_INI-CONF_603
               IF vn_moneinst <> vmoneprod
               THEN
                  vtdescrip := REPLACE (vtdescrip, '#5#', 'Parcial');
                  vitasa :=
                     pac_eco_tipocambio.f_cambio
                                       (pac_monedas.f_cmoneda_t (vmoneprod),
                                        pac_monedas.f_cmoneda_t (vn_moneinst),
                                        f_sysdate
                                       );
                  --viparcial_moncon := pac_monedas.f_round(viparcial / vitasa, vn_moneinst);
                  verror :=                                      --pac_md_con.
                     -- INI -IAXIS-4153 - JLTS - 07/06/2019
                     pac_adm_cobparcial.f_set_detmovrecibo (vnrecibo,
                                                            NULL,
                                                            -- psmovrec -- IAXIS-7640 04/12/2019
                                                            NULL,   -- pnorden
                                                            viparcial,
                                                            NULL,  -- pfmovimi
                                                            f_sysdate,
                                                            -- pfefeadm
                                                            NULL,  -- pcusuari
                                                            NULL,  -- psdevolu
                                                            NULL, -- pnnumnlin
                                                            NULL, -- pcbancar1
                                                            NULL,  -- pnnumord
                                                            NULL, -- psmovrecr
                                                            NULL,  -- pnordenr
                                                            vtdescrip,
                                                            viparcial_moncon,
                                                            psproces,
                                                            vimoncon,
                                                            vitasa,
                                                            f_sysdate,
                                                            pnreccaj,
                                                            pcmreca,
                                                            pctipotransap
                                                           );
                                                      -- IAXIS-4884 12/09/2019
               -- FIN -IAXIS-4153 - JLTS - 07/06/2019
               END IF;

                   --IGIL_FI-CONF_603
               --P_CONTROL_ERROR('JAAB','COBRA_TOTAL',pnrecibo);
               vpasexec := 120;
               -- INI -IAXIS-4153 - JLTS - 07/06/2019

               -----verror := pac_md_con.f_cobrar_recibo(vnrecibo, vctipcob, pnreccaj,pcmreca,vmensajes);
               verror :=
                  pac_md_con.f_cobrar_recibo (vnrecibo,
                                              vctipcob,
                                              pnreccaj,
                                              pcmreca,
                                              vmensajes,
                                              pcindicaf,
                                              v_city,
                                              pndocsap,
                                              pcususap
                                             );
                               ------changes for 4944 -- IAXIS-7640 04/12/2019
               -- FIN -IAXIS-4153 - JLTS - 07/06/2019
               vpasexec := 121;
               verror :=
                  pac_coa.f_insctacoas_parcial (vnrecibo,
                                                vcestrecat,
                                                vcempres,
                                                vsmovrec,
                                                f_sysdate
                                               );     -- IAXIS-7640 04/12/2019
               -- 5.0  0026022 - 0139541 - Final
            --INI RAL BUG 0037606: POS ADM Inconsistencia Reversión de Recaudo
            ELSIF viacumula_aux < 0
            THEN
               --El importe de la anulación de cobro parcial no puede ser superior al importe de los cobros parciales realizados
               verror := 9908554;
               RAISE e_object_error;
            --FIN RAL BUG 0037606: POS ADM Inconsistencia Reversión de Recaudo
            ELSE
               vpasexec := 130;

               IF vitotalr_monpol != 0
               THEN
                  vporcen := ROUND ((viacumula_aux * 100 / vitotalr_aux), 2);
               ELSE
                  vporcen := 0;
               END IF;

               vpasexec := 140;

               -- Si el piparcial es nulo grabará un nuevo pago por el resto de importe pendiente de pagar.
               IF viparcial = 0 OR viparcial IS NULL
               THEN
                  viparcial := vitotalr_aux - viacumula_aux;
               END IF;

               -- Cobro parcial de #1# acumula #2#, #3#% del importe total del recibo #4#. Tipo cobro #5#
               vpasexec := 150;
               vtdescrip := f_axis_literales (9904223, vcidioma);
               vpasexec := 160;
               vtdescrip := REPLACE (vtdescrip, '#1#', viparcial);
               vpasexec := 170;
               vtdescrip := REPLACE (vtdescrip, '#2#', viacumula_aux);
               vpasexec := 180;
               vtdescrip := REPLACE (vtdescrip, '#3#', vporcen);
               vpasexec := 190;
               vtdescrip := REPLACE (vtdescrip, '#4#', vitotalr_aux);

               IF pctipcob IS NOT NULL
               THEN
                  vpasexec := 200;
                  vtdescrip :=
                     REPLACE (vtdescrip,
                              '#5#',
                              ff_desvalorfijo (552, vcidioma, pctipcob)
                             );
               ELSE
                  vpasexec := 210;
                  vtdescrip := REPLACE (vtdescrip, '#5#', 'Parcial');
               END IF;

-- Bug 0026959 - DCG - 14/05/2013 -Ini
--Calculamos el importe del cobro parcial en la moneda contable
               vpasexec := 220;

               IF vn_moneinst <> vmoneprod
               THEN
                  IF pfcobparc IS NOT NULL
                  THEN
                     vpasexec := 240;
                     vfcambio := pfcobparc;
                  END IF;

                  vpasexec := 250;
      -- INI IAXIS-4153 - JLTS - 17/06/2019. Se comentariza la sicuiente sección de código
/*                  vitasa := pac_eco_tipocambio.f_cambio(pac_monedas.f_cmoneda_t(vmoneprod),
                                                        pac_monedas.f_cmoneda_t(vn_moneinst),
                                                        vfcambio);

                  IF vitasa IS NULL THEN
                     RETURN 9902592;
                  -- No se ha encontrado el tipo de cambio entre monedas
                  END IF;*/
                  -- FIN IAXIS-4153 - JLTS - 17/06/2019.

                  --
                  vpasexec := 260;
               END IF;

-- Bug 0026959 - DCG - 14/05/2013 - Fi
               vpasexec := 280;
               verror :=                                         --pac_md_con.
                  -- INI -IAXIS-4153 - JLTS - 07/06/2019
                  pac_adm_cobparcial.f_set_detmovrecibo (vnrecibo,
                                                         NULL,
                                                         -- psmovrec -- IAXIS-7640 04/12/2019
                                                         NULL,      -- pnorden
                                                         viparcial,
                                                         NULL,     -- pfmovimi
                                                         NULL,     -- pfefeadm
                                                         NULL,     -- pcusuari
                                                         NULL,     -- psdevolu
                                                         NULL,    -- pnnumnlin
                                                         NULL,    -- pcbancar1
                                                         NULL,     -- pnnumord
                                                         NULL,    -- psmovrecr
                                                         NULL,     -- pnordenr
                                                         vtdescrip,
                                                         viparcial_moncon,
                                                         psproces,
                                                         vimoncon,
                                                         vitasa,
                                                         f_sysdate,
                                                         pnreccaj,
                                                         pcmreca,
                                                         pctipotransap
                                                        );
                                                      -- IAXIS-4884 12/09/2019
               -- FIN -IAXIS-4153 - JLTS - 07/06/2019
                     -- Bug 0026959 - DCG - 30/07/2013

               -- Cobrar el recibo si el total de cobros parciales es igual al su importe total
               vpasexec := 290;
               verror :=
                  pac_coa.f_insctacoas_parcial (vnrecibo,
                                                vcestrecat,
                                                vcempres,
                                                vsmovrec,
                                                f_sysdate
                                               );     -- IAXIS-7640 04/12/2019

            --
-- INI AFM
            --
               IF NVL (viparcial, 0) = 0
               THEN
                  viacumula_aux := viacumula_aux + viparcial;
               END IF;

-- FIN AFM
            --
               -- INI IAXIS-4518 - JLTS -18/07/2019 - Ajkuste de redondeos
               IF     ROUND (viacumula_aux) = ROUND (vitotalr_aux)
                  -- FIN IAXIS-4518 - JLTS -18/07/2019 - Ajkuste de redondeos
                  AND NVL (pnocobrar, 0) = 0          -- 3.0 0022346 - 0127366
                  AND verror = 0
               THEN
                  vpasexec := 300;
--               verror := pac_gestion_rec.f_cobro_recibo(vcempres, pnrecibo, vfmovimi, vctipban, vcbancar, vccobban, vcdelega, vctipcob)
                  -- INI -IAXIS-4153 - JLTS - 07/06/2019
                  verror :=
                     pac_md_con.f_cobrar_recibo (vnrecibo,
                                                 vctipcob,
                                                 pnreccaj,
                                                 pcmreca,
                                                 vmensajes,
                                                 pcindicaf,
                                                 v_city /*pcsucursal*/,
                                                 pndocsap,
                                                 pcususap
                                                );
                                -----changes for 4944 -- IAXIS-7640 04/12/2019
               -- FIN -IAXIS-4153 - JLTS - 07/06/2019
               ELSE                                          --INI CONF-403 LR
                  -- INI -IAXIS-4153 - JLTS - 07/06/2019 Se ajusta el envío de los parámetros
                  verror :=
                     pac_ctrl_env_recibos.f_procesar_reccaus
                                           (vcempres,
                                            4,
                                            vnrecibo,
                                            vsmovrec, -- IAXIS-7640 04/12/2019
                                            1,
                                            NULL,
                                            vterror,
                                            vsinterf,
                                            1
                                           );                --FIN CONF-403 LR
               -- FIN -IAXIS-4153 - JLTS - 07/06/2019 Se ajusta el envío de los parámetros
               END IF;
            END IF;

            vpasexec := 310;

            -- JRB 03/07/2014 BUG 28528
            IF verror <> 0
            THEN
               RAISE e_object_error;
            END IF;
         --INI RAL BUG 0037606: POS ADM Inconsistencia Reversión de Recaudo
         ELSIF (vcestrecat = 1 AND viparcial < 0)
         THEN
            vpasexec := 330;
            viimporte_aux :=
               pac_adm_cobparcial.f_get_importe_cobro_parcial
                                               (vnrecibo,
                                                NULL,
                                                NULL, -- IAXIS-7640 04/12/2019
                                                vimoncon
                                               );
            vpasexec := 340;
            viacumula_aux := viimporte_aux + NVL (viparcial, 0);
            vpasexec := 350;

            IF vitotalr_aux != 0
            THEN
               vporcen := ROUND ((viacumula_aux * 100 / vitotalr_aux), 2);
            ELSE
               vporcen := 0;
            END IF;

            -- Cobro parcial de #1# acumula #2#, #3#% del importe total del recibo #4#. Tipo cobro #5#
            vpasexec := 360;
            vtdescrip := f_axis_literales (9904223, vcidioma);
            vpasexec := 370;
            vtdescrip := REPLACE (vtdescrip, '#1#', viparcial);
            vpasexec := 380;
            vtdescrip := REPLACE (vtdescrip, '#2#', viacumula_aux);
            vpasexec := 390;
            vtdescrip := REPLACE (vtdescrip, '#3#', vporcen);
            vpasexec := 400;
            vtdescrip := REPLACE (vtdescrip, '#4#', vitotalr_aux);
            vpasexec := 410;

            IF vn_moneinst <> vmoneprod
            THEN
               IF pfcobparc IS NULL
               THEN
                  vpasexec := 420;
                  vfcambio := f_sysdate;
               ELSE
                  vpasexec := 430;
                  vfcambio := pfcobparc;
               END IF;

               vpasexec := 440;
               vitasa :=
                  pac_eco_tipocambio.f_cambio
                                        (pac_monedas.f_cmoneda_t (vmoneprod),
                                         pac_monedas.f_cmoneda_t (vn_moneinst),
                                         vfcambio
                                        );

               IF vitasa IS NULL
               THEN
                  RETURN 9902592;
               -- No se ha encontrado el tipo de cambio entre monedas
               END IF;

               --
               vpasexec := 450;
               viparcial_moncon :=
                      pac_monedas.f_round (vitotalr_aux / vitasa, vn_moneinst);
            ELSE
               vpasexec := 460;
               viparcial_moncon := vitotalr_aux;
            END IF;

            -- Calculamos los días que cubren los cobros parciales
            IF vitotalr_aux != 0
            THEN
               vpasexec := 462;
               vdiascobra :=
                         (vfvencim - vfefecto) / vitotalr_aux * viacumula_aux;
               vpasexec := 464;
               pfcobrado := vfefecto + vdiascobra;
            ELSE
               vpasexec := 466;
               pfcobrado := NULL;
            END IF;

            --Descobrar el recibo, llamar a PAC_DEVOLU.f_impaga_rebut
            vpasexec := 468;
            verror :=
                   pac_devolu.f_impaga_rebut (vnrecibo, pfcobrado, NULL, NULL);

            -- IAXIS-7640 04/12/2019
            IF verror <> 0
            THEN
               RAISE e_object_error;
            END IF;

            vpasexec := 470;
                  --Hacer dos apuntes apuntes de cobro parcial, sobre el nuevo movimiento de recibo
                  --un apunte positivo por la totalidad del recibo
            -- INI -IAXIS-4153 - JLTS - 17/06/2019
            verror :=
               pac_adm_cobparcial.f_set_detmovrecibo (vnrecibo,
                                                      NULL,
                                                      -- psmovrec -- IAXIS-7640 04/12/2019
                                                      NULL,         -- pnorden
                                                      vitotalr_aux,
                                                      NULL,        -- pfmovimi
                                                      NULL,        -- pfefeadm
                                                      NULL,        -- pcusuari
                                                      NULL,        -- psdevolu
                                                      NULL,       -- pnnumnlin
                                                      NULL,       -- pcbancar1
                                                      NULL,        -- pnnumord
                                                      NULL,       -- psmovrecr
                                                      NULL,        -- pnordenr
                                                      vtdescrip,
                                                      viparcial_moncon,
                                                      psproces,
                                                      vimoncon,
                                                      vitasa,
                                                      f_sysdate,
                                                      pnreccaj,
                                                      pcmreca
                                                     );  -----Changes for 4753

            -- FIN -IAXIS-4153 - JLTS - 17/06/2019
            IF vn_moneinst <> vmoneprod
            THEN
               vpasexec := 480;
               viparcial_moncon :=
                        pac_monedas.f_round (viparcial * vitasa, vn_moneinst);
            ELSE
               vpasexec := 490;
               viparcial_moncon := viparcial;
            END IF;

            vpasexec := 500;
                  --y uno negativo del importe que acaba de llegar en la anulación
            -- INI -IAXIS-4153 - JLTS - 07/06/2019
            verror :=
               pac_adm_cobparcial.f_set_detmovrecibo (vnrecibo,
                                                      NULL,
                                                      -- psmovrec -- IAXIS-7640 04/12/2019
                                                      NULL,         -- pnorden
                                                      viparcial,
                                                      NULL,        -- pfmovimi
                                                      NULL,        -- pfefeadm
                                                      NULL,        -- pcusuari
                                                      NULL,        -- psdevolu
                                                      NULL,       -- pnnumnlin
                                                      NULL,       -- pcbancar1
                                                      NULL,        -- pnnumord
                                                      NULL,       -- psmovrecr
                                                      NULL,        -- pnordenr
                                                      vtdescrip,
                                                      viparcial_moncon,
                                                      psproces,
                                                      vimoncon,
                                                      vitasa,
                                                      f_sysdate,
                                                      pnreccaj,
                                                      pcmreca
                                                     );  -----Changes for 4753
             -- FIN -IAXIS-4153 - JLTS - 07/06/2019
         --FIN RAL BUG 0037606: POS ADM Inconsistencia Reversión de Recaudo
         END IF;

         -- 14.0 0028577#c156387 - Inicio
         IF     NVL (pac_parametros.f_parempresa_n (vcempres,
                                                    'AGENDA_COBRO_PARCIAL'
                                                   ),
                     0
                    ) = 1
            AND (   pnrecsap IS NOT NULL
                 OR pcususap IS NOT NULL
                 OR pctipcob IS NOT NULL
                )
         THEN
            -- 9906164 'Nº de recaudo en SAP : #1#'||CHR(10)||
            --         'Medio de cobro : #2#'||CHR(10)||
            --         'Usuario originador en SAP : #3#'
            vpasexec := 510;

            IF (vcestrecat = 1 AND vpermitedoble = 1)
            THEN
               vtextobs := f_axis_literales (9907659, vcidioma) || ' ';
            END IF;

            vpasexec := 515;
            vtextobs := vtextobs || f_axis_literales (9906164, vcidioma);
            vpasexec := 520;
            vtextobs := REPLACE (vtextobs, '#1#', pnrecsap);
            vpasexec := 530;

            BEGIN
               SELECT REPLACE (vtextobs, '#2#', tatribu)
                 INTO vtextobs
                 FROM detvalores
                WHERE cvalor = 1026
                  AND cidioma = vcidioma
                  AND catribu = vctipcob;
            EXCEPTION
               WHEN OTHERS
               THEN
                  vtextobs := REPLACE (vtextobs, '#2#', '???');
            END;

            vpasexec := 540;
            vtextobs := REPLACE (vtextobs, '#3#', pcususap);
            vpasexec := 560;
            verror := f_agd_observaciones (vcempres, vnrecibo, vtextobs);
         -- IAXIS-7640 04/12/2019
         END IF;

         -- 14.0 0028577#c156387 - Final
         IF verror <> 0
         THEN
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 570;
      pigenera := viparcial;
      COMMIT;                         ----------Changes for 4753 on 19/07/2019
      RETURN verror;
   EXCEPTION
      WHEN e_object_error
      THEN
         p_tab_error (f_sysdate, f_user, vobject, vpasexec, vparam, verror);
         RETURN verror;
      WHEN e_param_error
      THEN
         verror := 1000005;
         p_tab_error (f_sysdate, f_user, vobject, vpasexec, vparam, verror);
         RETURN verror;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN SQLCODE;
   END f_cobro_parcial_recibo;

-- Bug 0023130 - DCG - 19/10/2012 - LCOL_F002-Provisiones para polizas estatales
   FUNCTION f_get_porcentaje_cobro_parcial (
      pnrecibo   IN   NUMBER,
      psmovrec   IN   NUMBER DEFAULT NULL,
      pnorden    IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      vporcentaje   NUMBER          := 0;
      viimporte     NUMBER          := 0;
      vitotalr      NUMBER          := 0;
      vsmovrec      NUMBER          := psmovrec;
      vobject       VARCHAR2 (200)
                       := 'pac_adm_cobparcial.f_get_porcentaje_cobro_parcial';
      terror        VARCHAR2 (200);
      vpasexec      NUMBER (8)      := 1;
      vcempres      NUMBER          := 0;
      vsseguro      NUMBER          := 0;
      vparam        VARCHAR2 (2000)
         :=    'pnrecibo:'
            || pnrecibo
            || ' psmovrec:'
            || psmovrec
            || ' pnorden:'
            || pnorden;
   BEGIN
      vpasexec := 10;

      IF vsmovrec IS NULL
      THEN
         IF pnrecibo IS NULL
         THEN
            vpasexec := 20;
            RAISE e_param_error;
         ELSE
            vpasexec := 30;

            SELECT MAX (smovrec)
              INTO vsmovrec
              FROM movrecibo
             WHERE nrecibo = pnrecibo AND cestrec = 0;
         END IF;
      END IF;

      IF vsmovrec IS NOT NULL
      THEN
         vpasexec := 40;

         SELECT NVL (SUM (iimporte), 0)
           INTO viimporte
           FROM detmovrecibo
          WHERE norden = NVL (pnorden, norden) AND smovrec = vsmovrec;
      END IF;

      vpasexec := 50;

      SELECT cempres, sseguro
        INTO vcempres, vsseguro
        FROM recibos
       WHERE nrecibo = pnrecibo;

      IF NVL (pac_parametros.f_parempresa_n (vcempres, 'MONEDA_POL'), 0) = 1
      THEN
         -- vtabla vdetrecibos_monpol
         SELECT v.itotalr
           INTO vitotalr
           FROM recibos r, vdetrecibos_monpol v
          WHERE vsseguro = r.sseguro
            AND v.nrecibo = pnrecibo
            AND r.nrecibo = pnrecibo;
      ELSE
         -- tabla vdetrecibos
         SELECT v.itotalr
           INTO vitotalr
           FROM recibos r, vdetrecibos v
          WHERE vsseguro = r.sseguro
            AND v.nrecibo = pnrecibo
            AND r.nrecibo = pnrecibo;
      END IF;

      vporcentaje := viimporte / vitotalr;
      RETURN vporcentaje;
   EXCEPTION
      WHEN e_param_error
      THEN
         p_tab_error (f_sysdate, f_user, vobject, vpasexec, vparam, 1000005);
         RETURN 0;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 0;
   END f_get_porcentaje_cobro_parcial;

-- Fin Bug 0023130
   /******************************************************************************
   NAME:       F_CARGA_PAGOS_MASIVA
   PURPOSE:    Realiza el tratamiento de los recibos que vienen de los cobros de
               la carga Masiva.
               El importe que nos viene puede ser para un recibo o varios.
               Estos pagos pueden ser parciales, totales o para varios recibos.
               El criterio de pago es siempre del recibo mas antigüo al mas reciente.
   BUG:        26301
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        11/03/2013  mcg              1. Created this function.

   PARAMETRES:
      SPROCES  Nro de proceso
      SSEGURO  Clave de la póliza
      IMPORTE  Importe en moneda de producto.
      CMONPAG  Moneda de pago.
      IMPMPAG  Importe en moneda de pago.
      ITASA    Tasa que se ha aplicado al cambio.
      FMOVTO   Fecha del movimiento y cuando se ha aplicado la tasa de cambio.
      CULTPAGO Indica si es el último pago de la anualidad. 0-No y 1-Si

  ******************************************************************************/
   FUNCTION f_carga_pagos_masiva (
      psproces    IN   NUMBER,
      psperson    IN   NUMBER,
      psseguro    IN   NUMBER,
      pimporte    IN   NUMBER,
      pcmonpag    IN   NUMBER,
      pimpmpag    IN   NUMBER,
      pitasa      IN   NUMBER,
      pfmovto     IN   DATE,
      pcultpago   IN   NUMBER
   )
      RETURN NUMBER
   IS
      --
      vobject            VARCHAR2 (200)
                                 := 'pac_adm_cobparcial.f_carga_pagos_masiva';
      vpasexec           NUMBER (8)                          := 1;
      vparam             VARCHAR2 (2000)
         :=    'psproces:'
            || psproces
            || ' psperson:'
            || psperson
            || ' psseguro:'
            || psseguro
            || ' pimporte:'
            || pimporte
            || ' pcmonpag:'
            || pcmonpag
            || ' pimpmpag:'
            || pimpmpag
            || ' pitasa:'
            || pitasa
            || ' pfmovto:'
            || TO_CHAR (pfmovto, 'dd-mm-yyyy hh24:mi:ss')
            || ' pcultpago:'
            || pcultpago;
      vn_estado_insert   NUMBER                              := 0;
      --
      vn_cempres         NUMBER              := pac_md_common.f_get_cxtempresa;
      terror             VARCHAR2 (200);
      num_err            axis_literales.slitera%TYPE         := 0;
      -- Bug 0026959 - DCG - 14/05/2013 - FI
      v_fic              int_carga_ctrl.tfichero%TYPE;
      v_fec              int_carga_ctrl.fini%TYPE;
      v_spagmas          pagos_masivos.spagmas%TYPE;
      v_lin              pagos_masivosdet.numlin%TYPE;
      vn_cagente         seguros.cagente%TYPE;
      vn_sproduc         seguros.sproduc%TYPE;
      v_conta            NUMBER;
      v_isobrante        pagos_masivos_sobrante.saldo%TYPE;
      total_fichero      pagos_masivos.iimpins%TYPE;
      total_pagado       cajamov.iimpins%TYPE;
      v_seqcaja          cajamov.seqcaja%TYPE;
      vn_cdivisa         productos.cdivisa%TYPE;
      vn_monins          monedas.cmoneda%TYPE;
      v_impins           NUMBER                              := 0;
      vn_itasains        eco_tipocambio.itasa%TYPE;
   --
   BEGIN
      vpasexec := 1000;

      IF pcultpago = 1
      THEN
         SELECT COUNT (1)
           INTO v_conta
           FROM movseguro
          WHERE cmovseg = 1 AND fefecto > pfmovto AND sseguro = psseguro;

         IF v_conta = 0
         THEN
            -- No se puede tratar el último pago, ya que faltan recibos en la anualidad
            RETURN 9906130;
         END IF;
      --
      END IF;

      --
      vpasexec := 1010;

      --
      SELECT s.sproduc, s.cagente, p.cdivisa
        INTO vn_sproduc, vn_cagente, vn_cdivisa
        FROM seguros s, productos p
       WHERE p.sproduc = s.sproduc AND s.sseguro = psseguro;

      --
      BEGIN
         SELECT   COUNT (1), seqcaja
             INTO v_conta, v_seqcaja
             FROM pagos_masivos
            WHERE sproces = psproces
         GROUP BY seqcaja;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      --
      vpasexec := 1020;

      --
      IF v_conta > 0
      THEN
         SELECT COUNT (1)
           INTO v_conta
           FROM pagos_masivos
          WHERE sproces = psproces AND cagente <> vn_cagente;

         --
         IF v_conta > 0
         THEN
            -- Existe otro agente en el fichero
            RETURN 9906134;
         END IF;

         --
         SELECT COUNT (1)
           INTO v_conta
           FROM pagos_masivos
          WHERE sproces = psproces AND cmoneop <> pcmonpag;

         --
         IF v_conta > 0
         THEN
            -- No puede existir, en el fichero, más de una moneda diferente
            RETURN 9906135;
         END IF;
      --
      END IF;

      vpasexec := 1030;

      SELECT MAX (tfichero), MAX (fini)
        INTO v_fic, v_fec
        FROM int_carga_ctrl
       WHERE sproces = psproces;

      vpasexec := 1040;

      SELECT NVL (MAX (spagmas), 0) + 1
        INTO v_spagmas
        FROM pagos_masivos;

      -- Cabecera del fichero temporal
      BEGIN
         vpasexec := 1050;

         INSERT INTO pagos_masivos
                     (cagente, sproces, fcarga, tfichero, sproduc, iimppro,
                      cmoneop, iimpope, spagmas, iimpins
                     )
              VALUES (vn_cagente, psproces, v_fec, v_fic, vn_sproduc, 0,
                      pcmonpag, 0, v_spagmas, 0
                     );
      EXCEPTION
         WHEN OTHERS
         THEN
            -- Si ya existe, recupero el codigo
            vpasexec := 1060;

            SELECT NVL (MAX (spagmas), v_spagmas)
              INTO v_spagmas
              FROM pagos_masivos
             WHERE cagente = vn_cagente
               AND sproces = psproces
               AND tfichero = v_fic
               AND cmoneop = pcmonpag;

            vpasexec := 1070;
      /*
      UPDATE pagos_masivos
         SET iimppro = 0,
             iimpope = 0,
             iimpins = 0,
             iimptot = 0
       WHERE spagmas = v_spagmas;
      */
      END;

      vpasexec := 1080;
      -- Se graban los registros en una tabla intermedia
      vn_monins := f_parinstalacion_n ('MONEDAINST');

      IF vn_monins <> pcmonpag
      THEN
         vpasexec := 1090;
         vn_itasains :=
            pac_eco_tipocambio.f_cambio (pac_monedas.f_cmoneda_t (pcmonpag),
                                         pac_monedas.f_cmoneda_t (vn_monins),
                                         pfmovto
                                        );

         IF vn_itasains IS NULL
         THEN
            num_err := 9902592;
            RAISE e_param_error;
         -- No se ha encontrado el tipo de cambio entre monedas
         END IF;
      ELSE
         vn_itasains := 1;
      END IF;

      vpasexec := 1100;

      --
      -- Calcular el importe en moneda instalacion
      IF pcmonpag <> vn_monins
      THEN
         vpasexec := 1110;
         v_impins := pac_monedas.f_round (pimpmpag * vn_itasains, vn_monins);
      ELSE
         v_impins := pimpmpag;
      END IF;

      --
      vpasexec := 1120;

      --
      SELECT NVL (MAX (numlin), 0) + 1
        INTO v_lin
        FROM pagos_masivosdet
       WHERE spagmas = v_spagmas;

      --
      vpasexec := 1130;

      --
      INSERT INTO pagos_masivosdet
                  (spagmas, numlin, sperson, sseguro, nrecibo, fcambio,
                   iimppro, iimpope, iimpins, cultpag
                  )
           VALUES (v_spagmas, v_lin, psperson, psseguro, NULL, pfmovto,
                   pimporte, pimpmpag, v_impins, pcultpago
                  );

      --
      vpasexec := 1140;

      -- Esta pagado
      IF v_seqcaja IS NOT NULL
      THEN
         BEGIN
            SELECT saldo
              INTO v_isobrante
              FROM pagos_masivos_sobrante
             WHERE spagmas = v_spagmas
               AND numlin = (SELECT MAX (numlin)
                               FROM pagos_masivos_sobrante
                              WHERE spagmas = v_spagmas);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_isobrante := 0;
            WHEN OTHERS
            THEN
               v_isobrante := 0;
         END;

         vpasexec := 1150;

         -- Valido que no añadan más registros a los pagados por caja
         -- Si no hay sobrante y se genera nuevas cargas tiene que dar error
         IF NVL (v_isobrante, 0) > 0
         THEN
            SELECT SUM (iimpins)
              INTO total_fichero
              FROM pagos_masivosdet
             WHERE spagmas IN (SELECT spagmas
                                 FROM pagos_masivos
                                WHERE seqcaja = v_seqcaja);

            --
            BEGIN
               SELECT NVL (iimpins, 0) + NVL (iautliq, 0)
                 INTO total_pagado
                 FROM cajamov
                WHERE seqcaja = v_seqcaja;
            EXCEPTION
               WHEN OTHERS
               THEN
                  total_pagado := 0;
            END;

            --
            IF total_fichero > total_pagado
            THEN
               num_err := 9906278;
               RAISE e_param_error;
            END IF;
         --
         ELSE
            num_err := 9906278;
            RAISE e_param_error;
         END IF;

         vpasexec := 1160;

         -- Que lo pendiente no supere el sobrante
         BEGIN
            SELECT SUM (iimpins)
              INTO total_fichero
              FROM pagos_masivosdet
             WHERE spagmas = v_spagmas AND NVL (ctratar, 0) = 0;
         EXCEPTION
            WHEN OTHERS
            THEN
               total_fichero := 0;
         END;

         --
         IF NVL (total_fichero, 0) > v_isobrante
         THEN
            num_err := 9906279;
            RAISE e_param_error;
         END IF;
      --
      END IF;

      --
      vpasexec := 1170;
      --
      RETURN 0;
   --
   EXCEPTION
      WHEN e_param_error
      THEN
         p_tab_error (f_sysdate, f_user, vobject, vpasexec, vparam, num_err);
         RETURN num_err;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN SQLCODE;
   END f_carga_pagos_masiva;

--
   FUNCTION f_genera_recibo (
      pcempres       IN       NUMBER,
      psseguro       IN       NUMBER,
      pnrecibo       IN       NUMBER,
      pfefecto       IN       DATE,
      pfvencim       IN       DATE,
      pfgracia       IN       DATE,
      pnmovimi       IN       NUMBER,
      ptipocert      IN       VARCHAR2,
      pcmoneda       IN       NUMBER,
      pnrecibo_out   OUT      NUMBER,
      pctiprec       IN       NUMBER,
      pnfactor       IN       NUMBER,
      pgasexp        IN       NUMBER,
      psmovagr       IN       NUMBER DEFAULT 0
   --56. 0027378: LCOL_A005-Error en terminaciones por no pago ... - QT-7911
   )
      RETURN NUMBER
   IS
      vobjeto          VARCHAR2 (100) := 'pac_adm_cobparcial.f_genera_recibo';
      vtraza           NUMBER;
      num_err          NUMBER;
      salir            EXCEPTION;
      vnrecibo_aux     recibos.nrecibo%TYPE;
      vnrecibo_aux_1   recibos.nrecibo%TYPE;
      vnrecibo_aux_2   recibos.nrecibo%TYPE;
      v_nfactor        NUMBER;
      v_sproces        NUMBER                     := 1;
      vdecimals        NUMBER;
      reg_seg          seguros%ROWTYPE;
      vfvencim         DATE;
      -- 44. 0026314: LCOL_A003-Recibos con fecha efecto igual a fecha vencimiento
      vsmovagr         NUMBER                     := psmovagr;
      -- 56. 0027378: LCOL_A005-Error en terminaciones por no pago ... - QT-7911
      vnliqmen         NUMBER;
      vnliqlin         NUMBER;
      vcdelega         NUMBER;
      vproceslin       procesoslin.tprolin%TYPE;
      vextorn          NUMBER;                       -- 58. 0027644 - QT-8596
      v_nfactor2       NUMBER;                       -- 58. 0027644 - QT-8596
      vfactorx         NUMBER;                       -- 58. 0027644 - QT-8596
      vfmovini         DATE;                                   -- 64. 0010069
   BEGIN
      vtraza := 1;

      SELECT *
        INTO reg_seg
        FROM seguros
       WHERE sseguro = psseguro;

      -- 19292: CRE800 - Rebuts d'extorn i cessions (AXIS3186) - Inici
      BEGIN
         SELECT pac_monedas.f_moneda_producto (sproduc)
           INTO vdecimals
           FROM productos
          WHERE cramo = reg_seg.cramo
            AND cmodali = reg_seg.cmodali
            AND ctipseg = reg_seg.ctipseg
            AND ccolect = reg_seg.ccolect;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            num_err := 104347;              -- Producte no trobat a PRODUCTOS
            RAISE salir;
         WHEN OTHERS
         THEN
            num_err := 102705;                -- Error al llegir de PRODUCTOS
            RAISE salir;
      END;

      vtraza := 2;

      BEGIN
         /*
          {Creamos el recibo de tipo 14.-Tiempo transcurrido}
         */

         -- 44. 0026314: LCOL_A003-Recibos con fecha efecto igual a fecha vencimiento - Inicio
         vfvencim := NVL (pfgracia, pfvencim);

         IF vfvencim <= pfefecto
         THEN
            vfvencim := pfefecto + 1;
         END IF;

         -- 44. 0026314: LCOL_A003-Recibos con fecha efecto igual a fecha vencimiento - Fin

         -- Bug 23638: JRV -  LCOL_A001- Terminaci?n x no pago: error en els rebuts prorratejats  - Inici
         num_err :=
            f_insrecibo (psseguro,
                         NULL,
                         f_sysdate,
                         pfefecto,
                         -- 44. 0026314: LCOL_A003-Recibos con fecha efecto igual a fecha vencimiento - Inicio
                         -- NVL(pfgracia, pfvencim),
                         vfvencim,
                         -- 44. 0026314: LCOL_A003-Recibos con fecha efecto igual a fecha vencimiento - Fin
                         pctiprec,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         vnrecibo_aux,
                         'R',
                         NULL,
                         NULL,
                         pnmovimi,
                         f_sysdate,
                         ptipocert
                        );

         -- Bug 23638: JRV -  LCOL_A001- Terminaci?n x no pago: error en els rebuts prorratejats  - Fi
         /*
                 {El error 103108 , es un error controlado se genera el recibo}
         */
         IF num_err NOT IN (0, 103108)
         THEN
            RAISE salir;
         END IF;

         vtraza := 3;
      /*
      {borramos todos los conceptos}
      */
      EXCEPTION
         WHEN OTHERS
         THEN
            num_err := 105156;
            RAISE salir;
      END;

      vtraza := 4;

       /*
        {Se busca el factor de prorrateo}
       */
      -- Bug 23638: JRV -  LCOL_A001- Terminaci?n x no pago: error en els rebuts prorratejats  - Inici
      IF pnfactor IS NULL
      THEN
         v_nfactor := (pfgracia - pfefecto) / (pfvencim - pfefecto);
      ELSE
         v_nfactor := pnfactor;
      END IF;

      vtraza := 5;
      -- Bug 23638: JRV -  LCOL_A001- Terminaci?n x no pago: error en els rebuts prorratejats  - Fi
      /*
      {recuperamos y grabamos los conceptos del recibos a }
      */

      -- 26. 0023864/0124752 - 02/10/2012 - JGR - Inicio
      /*
      FOR c IN (SELECT r.nrecibo, d.cconcep, d.cgarant, NVL(d.nriesgo, 1) nriesgo,
                       DECODE(ctiprec, 9, -d.iconcep, d.iconcep) iconcep
                  FROM detrecibos d, recibos r
                 WHERE d.nrecibo = r.nrecibo
                   AND r.nrecibo = pnrecibo) LOOP
         -- Los gastos de expedicion (cconcep = 14) no se deben prorratear
      */

      --
      -- 58. 0027644: No se ha de prorratear los conceptos de 14 y 86 en los recibos de tiempo transcurrido - QT-8596 - Inicio
      vextorn := 1;

--      IF v_nfactor < 1 THEN
--         vextorn := pac_anulacion.f_concep_retorna_anul(psseguro, pnmovimi, reg_seg.sproduc,
--                                                        14, reg_seg.fanulac, vfactorx, 321);

      --         --  14 Gastos de expedición
--         --  86 IVA - Gastos de expedición

      --         --> Devuelve 0 si concepto 14 es retornable, quiere decir que NO lo ha de pagar el cliente,
--         --> el nuevo recibo si es prorratedo NO ha de tener conceptos 14 y 86

      --         --> Devuelve 1 y el recibo es prorrateado SÍ tendrá els 100% de la prima en los conceptos 14 y 86.
--         IF vextorn NOT IN(0, 1) THEN
--            num_err := vextorn;
--            RAISE salir;
--         END IF;
--      END IF;

      /*   33921  Eliminamos estos dos bucles y partimos del recibo de pago parcial ya creado
            -- 58. 0027644: No se ha de prorratear los conceptos de 14 y 86 en los recibos de tiempo transcurrido - QT-8596 - Final
            FOR c IN (SELECT r.nrecibo, d.cconcep, d.cgarant, NVL(d.nriesgo, 1) nriesgo,
                             DECODE(ctiprec, 9, -d.iconcep, d.iconcep) iconcep
                        FROM detrecibos d, recibos r
                       WHERE d.nrecibo = r.nrecibo
                         AND r.nrecibo = pnrecibo
                         AND d.cconcep NOT IN(SELECT ir.cconcep
                                                FROM imprec ir
                                               WHERE ir.ctipcon = 2
                                                 AND reg_seg.cramo = ir.cramo
                                                 AND reg_seg.cmodali = ir.cmodali
                                                 AND reg_seg.ctipseg = ir.ctipseg
                                                 AND reg_seg.ccolect = ir.ccolect
                                                 AND ir.cforpag = reg_seg.cforpag)) LOOP
               vtraza := 6;

               BEGIN

                  -- Los concepto 14 y 86, cuando toca incluirlos (vextorn = 1) no se prorratean, vextorn = 0 no los grabaremos
                  IF c.cconcep IN(14, 86) THEN
                     -- v_nfactor2 := vextorn;   --> vextorn solo puede ser 0 ó 1
                     v_nfactor2 := 1;
                  ELSE
                     v_nfactor2 := v_nfactor;
                  END IF;

                  IF v_nfactor2 != 0 THEN
                     INSERT INTO detrecibos
                                 (nrecibo, cconcep, cgarant, nriesgo,
                                  iconcep)
                          VALUES (vnrecibo_aux, c.cconcep, c.cgarant, c.nriesgo,
                                  NVL(f_round(c.iconcep * v_nfactor2, pcmoneda), 0));
                  END IF;
               -- 58. 0027644 - QT-8596 - Final

               -- 26. 0023864/0124752 - 02/10/2012 - JGR - Fin
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     BEGIN
                        vtraza := 10;

                        UPDATE detrecibos
                           SET iconcep = iconcep + f_round(c.iconcep
                                                                             -- 26. 0023864/0124752 - 02/10/2012 - Inicio
                                                                             --           * DECODE(c.cconcep, 14, 1 * pgasexp, v_nfactor),
                                                                    -- 58. 0027644 - QT-8596 - Inicio
                                                                    -- * v_nfactor,
                                                           * v_nfactor2,
                                                           -- 58. 0027644 - QT-8596 - Final
                                                           -- 26. 0023864/0124752 - 02/10/2012 - Fin
                                                           pcmoneda)
                         WHERE nrecibo = vnrecibo_aux
                           AND cconcep = c.cconcep
                           AND cgarant = c.cgarant
                           AND nriesgo = c.nriesgo;
                     EXCEPTION
                        WHEN OTHERS THEN
                           num_err := 104377;
                           RAISE salir;
                     --{ error al modificar recibos}
                     END;
                  WHEN OTHERS THEN
                     num_err := 103513;   --{error al insertar en detrecibos}
                     RAISE salir;
               END;
            END LOOP;

            vtraza := 20;

            -- 26. 0023864/0124752 - 02/10/2012 - JGR - Inicio
            FOR c IN (SELECT r.nrecibo, d.cconcep, d.cgarant, NVL(d.nriesgo, 1) nriesgo,
                             DECODE(ctiprec, 9, -d.iconcep, d.iconcep) iconcep
                        FROM detrecibos d, recibos r
                       WHERE d.nrecibo = r.nrecibo
                         AND r.nrecibo = pnrecibo
                         AND d.cconcep IN(SELECT ir.cconcep
                                            FROM imprec ir
                                           WHERE ir.ctipcon = 2
                                             AND reg_seg.cramo = ir.cramo
                                             AND reg_seg.cmodali = ir.cmodali
                                             AND reg_seg.ctipseg = ir.ctipseg
                                             AND reg_seg.ccolect = ir.ccolect
                                             AND ir.cforpag = reg_seg.cforpag)) LOOP
               vtraza := 30;

               BEGIN
                  -- 58. 0027644 - QT-8596 - Inicio

                  -- Los concepto 14 y 86, cuando toca incluirlos (vextorn = 1) no se prorratean, vextorn = 0 no los grabaremos
                  IF c.cconcep IN(14, 86) THEN
                     -- v_nfactor2 := vextorn;   --> vextorn solo puede ser 0 ó 1
                     v_nfactor2 := 1;
                  ELSE
                     v_nfactor2 := pgasexp;
                  END IF;

                  IF v_nfactor2 != 0 THEN
                     INSERT INTO detrecibos
                                 (nrecibo, cconcep, cgarant, nriesgo,
                                  iconcep)
                          VALUES (vnrecibo_aux, c.cconcep, c.cgarant, c.nriesgo,
                                  f_round(c.iconcep * v_nfactor2, pcmoneda));
                  END IF;
               -- 58. 0027644 - QT-8596 - Final
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     BEGIN
                        vtraza := 40;

                        UPDATE detrecibos
                           SET iconcep = iconcep + f_round(c.iconcep * pgasexp, pcmoneda)
                         WHERE nrecibo = vnrecibo_aux
                           AND cconcep = c.cconcep
                           AND cgarant = c.cgarant
                           AND nriesgo = c.nriesgo;
                     EXCEPTION
                        WHEN OTHERS THEN
                           num_err := 104377;
                           RAISE salir;
                     --{ error al modificar recibos}
                     END;
                  WHEN OTHERS THEN
                     num_err := 103513;   --{error al insertar en detrecibos}
                     RAISE salir;
               END;
            END LOOP;
            -- 26. 0023864/0124752 - 02/10/2012 - JGR - Fin
      --    Eliminamos estos dos bucles y partimos del recibo de pago parcial ya creado
      */

      --33921
      FOR c IN (SELECT nrecibo, cconcep, cgarant, NVL (nriesgo, 1) nriesgo,
                       
                       --DECODE(pctiprec, 9, -iconcep, iconcep) iconcep
                       iconcep
                  FROM detmovrecibo_parcial
                 WHERE nrecibo = pnrecibo
                   AND norden = (SELECT MAX (p.norden)
                                   FROM detmovrecibo_parcial p
                                  WHERE p.nrecibo = pnrecibo))
      LOOP
         INSERT INTO detrecibos
                     (nrecibo, cconcep, cgarant, nriesgo,
                      iconcep
                     )
              VALUES (vnrecibo_aux, c.cconcep, c.cgarant, c.nriesgo,
                      NVL (f_round (c.iconcep, pcmoneda), 0)
                     );
      END LOOP;

      vtraza := 50;                                                       -- 7

       /*
      { restauramos los totales del recibo}
      */
      -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
      DELETE FROM vdetrecibos_monpol
            WHERE nrecibo = vnrecibo_aux;

      vtraza := 60;                                                       -- 8

      -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
      DELETE      vdetrecibos
            WHERE nrecibo = vnrecibo_aux;

      vtraza := 70;                                                       -- 9
      num_err := f_vdetrecibos ('R', vnrecibo_aux);

      IF num_err != 0
      THEN
         RAISE salir;
      END IF;

      -- 64. 0010069: VG CONTRIBUTIVO ERROR GENERACION DE RECIBOS AL SUBIR ASEGURADO - Inicial
      -- Generamos el corretaje del recibo
      vtraza := 75;                                                     -- 9,5

      IF pac_corretaje.f_tiene_corretaje (psseguro, NULL) = 1
      THEN
-- Bug 30548 10/03/2014, se elimina el pnmovimi, se envia a NUL para que busque si tiene co-corretaje
         num_err :=
            pac_corretaje.f_reparto_corretaje (psseguro,
                                               pnmovimi,
                                               vnrecibo_aux
                                              );
      END IF;

      IF num_err != 0
      THEN
         RAISE salir;
      END IF;

      -- 64. 0010069: VG CONTRIBUTIVO ERROR GENERACION DE RECIBOS AL SUBIR ASEGURADO - Final
      vtraza := 80;                                                      -- 10
      num_err :=
         pac_cesionesrea.f_cessio_det (v_sproces,
                                       psseguro,
                                       vnrecibo_aux,
                                       reg_seg.cactivi,
                                       reg_seg.cramo,
                                       reg_seg.cmodali,
                                       reg_seg.ctipseg,
                                       reg_seg.ccolect,
                                       pfefecto,
                                       --pfgracia,
                                       pfvencim,     --JAMF  33921  23/01/2015
                                       1,
                                       vdecimals
                                      );

      IF num_err != 0
      THEN
         RAISE salir;
      END IF;

      vtraza := 90;
      pnrecibo_out := vnrecibo_aux;
      -- Ini 26719 -- ECP -- 15/04/2013
      vtraza := 100;

      -- 49. 0026719: LCOL_A001-Incidencias en proceso de terminaciones por no pago. - 0145148 - Inicio
      -- Solo se puede permitir la anulación si el recibo está pendiente 0, ni remesado 3
      IF f_cestrec (pnrecibo, NULL) = 0
      THEN
         vtraza := 110;

         -- 49. 0026719: LCOL_A001-Incidencias en proceso de terminaciones por no pago. - 0145148 - Final

         -- 64. 0010069 - Final
         SELECT GREATEST (fmovini, pfgracia)
           INTO vfmovini
           FROM movrecibo
          WHERE nrecibo = pnrecibo AND fmovfin IS NULL;

         vtraza := 120;
         --num_err := f_movrecibo(pnrecibo, 2, pfgracia, 2, vsmovagr, vnliqmen, vnliqlin,
         --                       pfgracia, NULL, vcdelega, NULL, NULL);
         num_err :=
            f_movrecibo (pnrecibo,
                         2,
                         pfgracia,
                         2,
                         vsmovagr,
                         vnliqmen,
                         vnliqlin,
                         vfmovini,
                         NULL,
                         vcdelega,
                         -- 76. 0029431  Rehabilitación anule recibos (ctiprec = 14) - Inicio
                         -- NULL,
                         0,                                        -- pcmotmov
                         -- 76. 0029431  Rehabilitación anule recibos (ctiprec = 14) - Final
                         NULL
                        );

         -- 64. 0010069 - Final
         IF num_err != 0
         THEN
            RAISE salir;
         END IF;
      END IF;

      -- Fin 26719 -- ECP -- 15/04/2013
      RETURN 0;
   EXCEPTION
      WHEN salir
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_adm_cobparcial.f_genera_recibo',
                      vtraza,
                      num_err,
                      f_axis_literales (num_err)
                     );
         RETURN num_err;
      WHEN OTHERS
      THEN
         num_err := 1000455;                          -- Error no controlado.
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_adm_cobparcial.f_genera_recibo',
                      vtraza,
                      num_err,
                      SQLERRM
                     );
         RETURN num_err;
   END f_genera_recibo;

     --INI -IAXIS-7584 -JLTS -06/04/2020
    /******************************************************************************
    NAME:       F_GET_IMPORTE_COBRADO
    PURPOSE:    Seleccionar el valor según concepto y recibo del último movimiento de
                pago parcial realizado
    BUG:        IAXIS-7584

    PARAMETRES:
       pnrecibo Número de recibo
       pcconcep Concepto prima neta (0,50),IVA (4), etc.
       piconcep concepto en pesos o moneda extrangera (1) ME y (2) COP

   ******************************************************************************/
   FUNCTION f_get_importe_cobrado (
      pnrecibo   recibos.nrecibo%TYPE,
      pcconcep   detmovrecibo_parcial.cconcep%TYPE,
      piconcep   NUMBER
   )
      RETURN NUMBER
   IS
      v_saldo   detmovrecibo_parcial.iconcep%TYPE   := -1;
   BEGIN
      IF piconcep IS NOT NULL
      THEN
         IF pcconcep = 0
         THEN
            -- 0 y 50
            SELECT (CASE
                       WHEN piconcep = 1
                          THEN SUM (d.iconcep)
                       ELSE SUM (d.iconcep_monpol)
                    END
                   ) valor
              INTO v_saldo
              FROM detmovrecibo_parcial d
             WHERE d.nrecibo IN (pnrecibo)
               AND d.norden =
                      (SELECT MAX (d1.norden)
                         FROM detmovrecibo_parcial d1
                        WHERE d1.smovrec = d.smovrec
                          AND d1.cconcep = d.cconcep
                          AND d1.cgarant = d.cgarant
                          AND d1.nriesgo = d.nriesgo)
               AND d.cconcep IN (0, 50);
         ELSE
            SELECT (CASE
                       WHEN piconcep = 1
                          THEN SUM (d.iconcep)
                       ELSE SUM (d.iconcep_monpol)
                    END
                   ) valor
              INTO v_saldo
              FROM detmovrecibo_parcial d
             WHERE d.nrecibo IN (pnrecibo)
               AND d.norden =
                      (SELECT MAX (d1.norden)
                         FROM detmovrecibo_parcial d1
                        WHERE d1.smovrec = d.smovrec
                          AND d1.cconcep = d.cconcep
                          AND d1.cgarant = d.cgarant
                          AND d1.nriesgo = d.nriesgo)
               AND d.cconcep IN (pcconcep);
         END IF;
      END IF;

      RETURN v_saldo;
   END f_get_importe_cobrado;
--FIN -IAXIS-7584 -JLTS -06/04/2020
END pac_adm_cobparcial;
/