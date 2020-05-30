--------------------------------------------------------
--  DDL for Package Body PAC_GESTION_RETENIDAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_GESTION_RETENIDAS" AS
/******************************************************************************
   NOMBRE:     PAC_GESTION_RETENIDAS
   PROPÓSITO:  Package que contiene las funciones para la Gestión de las Propuestas Retenidas.

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   2.0        03/03/2009   DRA                2. BUG0009297: IAX - Gestió de propostes - Revisió punts pendents
   3.0        16/03/2009   DRA                3. BUG0009423: IAX - Gestió propostes retingudes: detecció diferències al modificar capitals o afegir garanties
   4.0        04/02/2014   FAL                4. 0029965: RSA702 - GAPS renovación
   5.0        01/04/2014   KBR                5. 0030702: POSPG400-POSREA-V.I.REASEGUROS
******************************************************************************/
   FUNCTION f_lanzar_tipo_mail(
      psseguro IN NUMBER,
      pctipo IN NUMBER,
      pcidioma IN NUMBER,
      pcaccion IN VARCHAR2,
      pmail OUT VARCHAR2,
      pasunto OUT VARCHAR2,
      pfrom OUT VARCHAR2,
      pto OUT VARCHAR2,
      pto2 OUT VARCHAR2)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
      clausulas      NUMBER;
      sobreprima     NUMBER;
      exclusiones    NUMBER;
      verror         VARCHAR2(300);
   BEGIN
      IF pctipo = 3 THEN   --Petición información
         num_err := pac_correo.f_mail(11, psseguro, 1, pcidioma, pcaccion, pmail, pasunto,
                                      pfrom, pto, pto2, verror);
      ELSIF pctipo = 4 THEN   --Petición información
         num_err := pac_correo.f_mail(13, psseguro, 1, pcidioma, pcaccion, pmail, pasunto,
                                      pfrom, pto, pto2, verror);
      ELSIF pctipo = 2 THEN   -- Rechazo de poliza
         num_err := pac_correo.f_mail(10, psseguro, 1, pcidioma, pcaccion, pmail, pasunto,
                                      pfrom, pto, pto2, verror);
      ELSIF pctipo IN(1, 5, 6) THEN
         -- buscamos el caso de mail
         --clausulas
         SELECT COUNT(1)
           INTO clausulas
           FROM clausuesp
          WHERE sseguro = psseguro
            AND ffinclau IS NULL
            AND cclaesp = 2;

         IF clausulas > 1 THEN
            clausulas := 1;
         END IF;

         -- sobreprima
         SELECT SUM(NVL(irecarg, 0))
           INTO sobreprima
           FROM garanseg
          WHERE sseguro = psseguro
            AND ffinefe IS NULL;

         IF sobreprima > 1 THEN
            sobreprima := 1;
         END IF;

         --exclusiones
         SELECT COUNT(1)
           INTO exclusiones
           FROM exclugarseg
          WHERE sseguro = psseguro
            AND nmovimb IS NULL;

         IF exclusiones > 1 THEN
            exclusiones := 1;
         END IF;

         IF pctipo = 5 THEN
            num_err := pac_correo.f_mail(12, psseguro, 1, pcidioma, pcaccion, pmail, pasunto,
                                         pfrom, pto, pto2, verror);
         ELSIF pctipo = 6 THEN   -- BUG9423:16/03/2009:DRA: Si es una prop.suplemento
            num_err := pac_correo.f_mail(22, psseguro, 1, pcidioma, pcaccion, pmail, pasunto,
                                         pfrom, pto, pto2, verror);
         ELSE
            IF sobreprima = 0
               AND clausulas = 0
               AND exclusiones = 0 THEN
               -- sin nada . Doc 2
               num_err := pac_correo.f_mail(2, psseguro, 1, pcidioma, pcaccion, pmail,
                                            pasunto, pfrom, pto, pto2, verror);
            ELSIF sobreprima = 0
                  AND clausulas = 1
                  AND exclusiones = 0 THEN
               -- solo clausulas . Doc 3
               num_err := pac_correo.f_mail(3, psseguro, 1, pcidioma, pcaccion, pmail,
                                            pasunto, pfrom, pto, pto2, verror);
            ELSIF sobreprima = 1
                  AND clausulas = 0
                  AND exclusiones = 0 THEN
               -- solo sobreprimas. Doc 4
               num_err := pac_correo.f_mail(4, psseguro, 1, pcidioma, pcaccion, pmail,
                                            pasunto, pfrom, pto, pto2, verror);
            ELSIF sobreprima = 1
                  AND clausulas = 1
                  AND exclusiones = 0 THEN
               -- sobreprimas y clausulas 5
               num_err := pac_correo.f_mail(5, psseguro, 1, pcidioma, pcaccion, pmail,
                                            pasunto, pfrom, pto, pto2, verror);
            ELSIF sobreprima = 0
                  AND clausulas = 0
                  AND exclusiones = 1 THEN
               -- solo exclusiones Doc. 6
               num_err := pac_correo.f_mail(6, psseguro, 1, pcidioma, pcaccion, pmail,
                                            pasunto, pfrom, pto, pto2, verror);
            ELSIF sobreprima = 1
                  AND clausulas = 0
                  AND exclusiones = 1 THEN
               -- exclusiones y sobreprima 7
               num_err := pac_correo.f_mail(7, psseguro, 1, pcidioma, pcaccion, pmail,
                                            pasunto, pfrom, pto, pto2, verror);
            ELSIF sobreprima = 0
                  AND clausulas = 1
                  AND exclusiones = 1 THEN
               -- exclusiones y clausulas 8
               num_err := pac_correo.f_mail(8, psseguro, 1, pcidioma, pcaccion, pmail,
                                            pasunto, pfrom, pto, pto2, verror);
            ELSIF sobreprima = 1
                  AND clausulas = 1
                  AND exclusiones = 1 THEN
               -- Todo 9
               num_err := pac_correo.f_mail(9, psseguro, 1, pcidioma, pcaccion, pmail,
                                            pasunto, pfrom, pto, pto2, verror);
            END IF;
         END IF;
      -- BUG 29965 - FAL - 03/02/2014
      ELSIF pctipo = 7 THEN
         num_err := pac_correo.f_mail(109, psseguro, 1, pcidioma, pcaccion, pmail, pasunto,
                                      pfrom, pto, pto2, verror);
      -- BUG 29965 - FAL - 03/02/2014
      END IF;

      RETURN num_err;
   END f_lanzar_tipo_mail;

   FUNCTION f_aceptar_propuesta(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pfecha IN DATE DEFAULT NULL,
      ptobserv IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      num_err        NUMBER;
      vparampsu      NUMBER;
      vsproduc       NUMBER;
   BEGIN
      num_err := pac_propio.f_aceptar_propuesta(psseguro, pnmovimi, pnriesgo, pfecha,
                                                ptobserv);

      IF num_err = 0 THEN
         SELECT sproduc
           INTO vsproduc
           FROM seguros
          WHERE sseguro = psseguro;

         vparampsu := pac_parametros.f_parproducto_n(vsproduc, 'PSU');

         IF NVL(vparampsu, 0) = 0 THEN
            UPDATE motretencion
               SET cestgest = 6
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND nmovimi = pnmovimi;
         ELSIF NVL(vparampsu, 0) = 1 THEN
            --if psu XPL
            UPDATE psu_retenidas
               SET cmotret = 0,
                   observ = ptobserv,
                   cusuaut = f_user,
                   ffecaut = f_sysdate
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi;
         END IF;

         COMMIT;
      END IF;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END f_aceptar_propuesta;

   FUNCTION f_rechazar_propuesta(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pcmotmov IN NUMBER,
      pnsuplem IN NUMBER,
      ptobserv IN VARCHAR2,
      ptpostpper IN psu_retenidas.postpper%TYPE,
      pcperpost IN psu_retenidas.perpost%TYPE)
      RETURN NUMBER IS
      num_err        NUMBER;
      vparampsu      NUMBER;
      vsproduc       NUMBER;
   BEGIN
      num_err := pac_propio.f_rechazar_propuesta(psseguro, pnmovimi, pnriesgo, pcmotmov,
                                                 pnsuplem, ptobserv);

      IF num_err = 0 THEN
         SELECT sproduc
           INTO vsproduc
           FROM seguros
          WHERE sseguro = psseguro;

         vparampsu := pac_parametros.f_parproducto_n(vsproduc, 'PSU');

         IF NVL(vparampsu, 0) = 0 THEN
            UPDATE motretencion
               SET cestgest = 6
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND nmovimi = pnmovimi;
         ELSIF NVL(vparampsu, 0) = 1 THEN
            --if psu XPL
            UPDATE psu_retenidas
               SET cmotret = 4,
                   observ = ptobserv,
                   cusuaut = f_user,
                   cdetmotrec = pcmotmov,   -- Bug 20759 M.R.B. 13/01/2012
                   ffecaut = f_sysdate,
                   postpper = ptpostpper,
                   perpost = pcperpost
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi;
         END IF;

         COMMIT;
      END IF;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END f_rechazar_propuesta;

   FUNCTION f_cambio_fcancel(psseguro IN NUMBER, pnmovimi IN NUMBER, pfcancel_nou IN DATE)
      RETURN NUMBER IS
      num_err        NUMBER;
   BEGIN
      num_err := pac_propio.f_cambio_fcancel(psseguro, pnmovimi, pfcancel_nou);
      RETURN num_err;
   END f_cambio_fcancel;

   FUNCTION f_cambio_sobreprima(psseguro IN NUMBER, pnmovimi IN NUMBER, pnriesgo IN NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER;
   BEGIN
      num_err := pac_propio.f_cambio_sobreprima(psseguro, pnmovimi, pnriesgo);
      RETURN num_err;
   END f_cambio_sobreprima;

   FUNCTION f_cambio_clausulas(psseguro IN NUMBER, pnmovimi IN NUMBER, pnriesgo IN NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER;
   BEGIN
      num_err := pac_propio.f_cambio_clausulas(psseguro, pnmovimi, pnriesgo);
      RETURN num_err;
   END f_cambio_clausulas;

   FUNCTION f_estado_propuesta(psseguro IN NUMBER, pcreteni OUT NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER;
   BEGIN
      --30702 KBR se agrega el estado 17: Propuesta cartera para renovación de cartera POS
      SELECT s.creteni
        INTO pcreteni
        FROM seguros s
       WHERE s.sseguro = psseguro
         AND s.csituac IN(4, 5, 12, 17);   -- proyecto generico

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 112131;
   END f_estado_propuesta;

   FUNCTION f_act_estadogestion(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcmotret IN NUMBER,
      pnmotret IN NUMBER,
      pcestgest IN NUMBER,
      ptodos IN NUMBER)
      RETURN NUMBER IS
      nerror         NUMBER;
   BEGIN
      IF ptodos = 1 THEN
         UPDATE motretencion
            SET cestgest = pcestgest
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi;
      ELSE
         UPDATE motretencion
            SET cestgest = pcestgest
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi
            AND cmotret = pcmotret
            AND nmotret = pnmotret;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         RETURN SQLCODE;
   END f_act_estadogestion;
END pac_gestion_retenidas;

/

  GRANT EXECUTE ON "AXIS"."PAC_GESTION_RETENIDAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_GESTION_RETENIDAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_GESTION_RETENIDAS" TO "PROGRAMADORESCSI";
