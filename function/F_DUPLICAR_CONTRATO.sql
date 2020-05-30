--------------------------------------------------------
--  DDL for Function F_DUPLICAR_CONTRATO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DUPLICAR_CONTRATO" (
   pscontra IN NUMBER,
   pnversio IN NUMBER,
   pramoc IN NUMBER DEFAULT NULL,
   pmodalic IN NUMBER DEFAULT NULL,
   pcolectc IN NUMBER DEFAULT NULL,
   ptipsegc IN NUMBER DEFAULT NULL,
   pactivic IN NUMBER DEFAULT NULL,
   pgarantc IN NUMBER DEFAULT NULL)
   RETURN NUMBER IS
/************************************************************************************************
   F_Duplicar_contrato:    Duplica un contracte de reassegurança
                           Paràmetres : Pasem el SCONTRA i NVERSIO del contracte
                           a copiar i CRAMO,CMODALI,CCOLECT,CTIPSEG, CACTIVI i CGARANT
                                        del contracte nou.
REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  -------  -------------------------------------
      1.0        XX/XX/XXXX   XXX     1. Creación de la función.
      2.0        14/05/2010   AVT     2. 14536: CRE200 - Reaseguro: Se requiere que un contrato se pueda utilizar
                                                en varias agrupaciones de producto
      3.0        25/05/2012   AVT     3. 22076: LCOL_A004-Mantenimientos de cuenta tecnica del reaseguro y del coaseguro
*************************************************************************************************/
   contra         NUMBER;
   fini           DATE;
   ffin           DATE;
BEGIN
   SELECT scontra.NEXTVAL
     INTO contra
     FROM DUAL;

   fini := f_sysdate;
   ffin := f_sysdate;

   -- Insert a CODICONTRATOS
   BEGIN
      INSERT INTO codicontratos
                  (scontra, spleno, cempres, ctiprea, finictr, ffinctr, nconrel, sconagr,
                   cvidaga, cvidair, cvalid, ctipcum)
         SELECT contra, spleno, cempres, ctiprea, fini, ffinctr, nconrel, sconagr, cvidaga,
                cvidair, NULL, ctipcum
           FROM codicontratos
          WHERE scontra = pscontra;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 104070;   -- error a l'insert de CODICONTRATOS
   END;

   -- Insert a AGR_CONTRATOS 14536 14-05-2010 AVT
   BEGIN
      INSERT INTO agr_contratos
                  (cramo, cactivi, cmodali, ccolect, ctipseg, cgarant)
         SELECT pramoc, pactivic, pmodalic, pcolectc, ptipsegc, pgarantc
           FROM agr_contratos
          WHERE scontra = pscontra;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 104070;   -- error a l'insert de CODICONTRATOS
   END;

   -- Insert a CONTRATOS
   --INI - EDBR - 11/06/2019 - IAXIS3338 - se agrega campos para los campo de Retencion por poliza NRETPOL y Retencion por Cumulo NRETCUL
   BEGIN
      INSERT INTO contratos
                  (scontra, nversio, npriori, fconini, nconrel, fconfin, iautori, iretenc,
                   iminces, icapaci, iprioxl, ppriosl, tcontra, tobserv, pcedido, priesgos,
                   pdescuento, pgastos, ppartbene, creafac, nretpol, nretcul)
         SELECT contra, 1, npriori, fini, nconrel, ffin, iautori, iretenc, iminces, icapaci,
                iprioxl, ppriosl, 'Contracte Duplicat', tobserv, pcedido, priesgos,
                pdescuento, pgastos, ppartbene, creafac, nretpol, nretcul
           FROM contratos
          WHERE scontra = pscontra
            AND nversio = pnversio;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 103818;   -- error a l'inserir a CONTRATOS
   END;
	--FIN - EDBR - 11/06/2019 - IAXIS3338 - se agrega campos para los campo de Retencion por poliza NRETPOL y Retencion por Cumulo NRETCUL

   -- Insert a TRAMOS
   BEGIN
      INSERT INTO tramos
                  (nversio, scontra, ctramo, itottra, nplenos, cfrebor, plocal, ixlprio,
                   ixlexce, pslprio, pslexce, ncesion, fultbor, imaxplo, norden, nsegcon,
                   nsegver)
         SELECT 1, contra, ctramo, itottra, nplenos, cfrebor, plocal, ixlprio, ixlexce,
                pslprio, pslexce, ncesion, fultbor, imaxplo, norden, nsegcon, nsegver
           FROM tramos
          WHERE scontra = pscontra
            AND nversio = pnversio;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 103819;   -- error a l'inserir a TRAMOS
   END;

   -- Insert a CUADROCES
   BEGIN
      INSERT INTO cuadroces
                  (ccompani, nversio, scontra, ctramo, ccomrea, pcesion, nplenos, icesfij,
                   icomfij, isconta, preserv, pintres, iliacde, ppagosl, ccorred, cintres)
         SELECT ccompani, 1, contra, ctramo, ccomrea, pcesion, nplenos, icesfij, icomfij,
                isconta, preserv, pintres, iliacde, ppagosl, ccorred, cintres
           FROM cuadroces
          WHERE scontra = pscontra
            AND nversio = pnversio;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 103820;   -- error a l'inserir a CUADROCES
   END;

   -- Insert a CTATECNICA
   BEGIN
      INSERT INTO ctatecnica
                  (ccompani, nversio, scontra, ctramo, nctatec, cfrecul, cestado, festado,
                   fcierre, cempres, sproduc, ccorred)   -- 22076 AVT 25/05/2012 afegits camps a la taula (fcierre, cempres, sproduc, ccorred)
         SELECT ccompani, 1, contra, ctramo, nctatec, cfrecul, cestado, festado, fcierre,
                cempres, sproduc, ccorred
           FROM ctatecnica
          WHERE scontra = pscontra
            AND nversio = pnversio;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 104861;   -- error a l'inserir a CTATECNICA
   END;

   -- Insert a REAFORMULA
   BEGIN
      INSERT INTO reaformula
                  (scontra, nversio, cgarant, ccampo, clave)
         SELECT contra, 1, cgarant, ccampo, clave
           FROM reaformula
          WHERE scontra = pscontra
            AND nversio = pnversio;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 104861;   -- error a l'inserir a CTATECNICA
   END;

   COMMIT;
   RETURN 0;
END f_duplicar_contrato;

/

  GRANT EXECUTE ON "AXIS"."F_DUPLICAR_CONTRATO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DUPLICAR_CONTRATO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DUPLICAR_CONTRATO" TO "PROGRAMADORESCSI";
