--------------------------------------------------------
--  DDL for Function F_APORTACIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_APORTACIONS" (
   pssolicit IN NUMBER,
   vfefecto IN DATE,   --DIA DE LA SIMULACIÓN
   vfvenci IN DATE,
   vfinicial IN DATE,   --DIA QUE EMPIEZAN LAS APORTACIONES
   vfrevision IN DATE,   --FECHA EFECTO DEL CRECIMIENTO ACUMULATIVO
   vaportainicial IN NUMBER,
   vaportaperiodica IN NUMBER,
   vcreixement IN NUMBER,
   vtiporevali IN NUMBER   --1 CRECIMIENTO LINEAL; 2 CRECIMIENTO ACUMULATIVO
                        )
   RETURN NUMBER IS
   nerror         NUMBER;
   vfinic         DATE;
   vfvenc         DATE;
   vmesesfaltan   NUMBER;
   vperiodo       NUMBER;
   vany           NUMBER;
   vmesinicial    NUMBER;
   vanyrevision   NUMBER;
   vmesrevision   NUMBER;
   vforma         NUMBER;
   vtotalmeses    NUMBER;
   vnmes          NUMBER;
   vaportames     NUMBER;
   vanyaportainicial NUMBER;
   vfpago         DATE;
   vfechaconv     DATE;
   vnuevafecha    VARCHAR2(8);
   vmessig        NUMBER;

   CURSOR formaspago IS
      SELECT cforpag
        FROM solseguros
       WHERE ssolicit = pssolicit;

   FUNCTION f_siguientemes(vsuma IN NUMBER)
      RETURN NUMBER IS
      vresultado     NUMBER;
   BEGIN
      vresultado := MOD(vsuma, 12);
      RETURN vresultado;
   END;

   FUNCTION f_inserta(
      pssolicit IN NUMBER,
      vpago IN NUMBER,
      fpago IN DATE,
      vprima IN NUMBER,
      vany IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      INSERT INTO tmp_aportaciones
                  (ssolicit, nany, npago, fpago, iprima)
           VALUES (pssolicit, vany, vpago, fpago, vprima);

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN -1;
   END;

   FUNCTION f_revalorizacion(
      vtiporevali IN NUMBER,
      vforma IN NUMBER,
      vaportaperiodica IN NUMBER,
      vcreixement IN NUMBER,
      vmes IN NUMBER)
      RETURN NUMBER IS
      vtotal         NUMBER;
      vcoeficiente   NUMBER;
   BEGIN
      vcoeficiente := TRUNC(vmes / vforma);

      IF vtiporevali = 1 THEN
         vtotal := f_round(vaportaperiodica *(1 +((vcreixement / 100) * vcoeficiente)));
      END IF;

      IF vtiporevali = 2 THEN
         vtotal := f_round(vaportaperiodica * POWER((1 +(vcreixement / 100)), vcoeficiente));
      END IF;

      RETURN vtotal;
   END;
BEGIN
   OPEN formaspago;

   FETCH formaspago
    INTO vforma;

   IF formaspago%NOTFOUND THEN
      vforma := 12;   --MENSUAL
   END IF;

   CLOSE formaspago;

   IF vforma = 1 THEN
      --******************* primas periódicas anuales *******************--
      vanyaportainicial := TO_NUMBER(SUBSTR(TO_CHAR(vfefecto, 'DDMMYYYY'), 5));
      --el fpago coincide con la fecha de efecto
      nerror := f_inserta(pssolicit, 0, vfefecto, vaportainicial, vanyaportainicial);
      vany := TO_NUMBER(SUBSTR(TO_CHAR(vfinicial, 'DDMMYYYY'), 5));

      IF nerror = 0 THEN
         --PRIMER AÑO
         vmesinicial := TO_NUMBER(SUBSTR(TO_CHAR(vfinicial, 'DDMMYYYY'), 3, 2));
         --una única aportación
         --el fpago coincide con la fecha de inicio
         vfpago := vfinicial;
         nerror := f_inserta(pssolicit, 1, vfpago, vaportaperiodica, vany);

         IF nerror = 0 THEN
            vnmes := 2;

            --RESTO DE AÑOS HASTA FECHA DE VENCIMIENTO
            IF nerror = 0 THEN
               vanyrevision := TO_NUMBER(SUBSTR(TO_CHAR(vfrevision, 'DDMMYYYY'), 5));
               vmesrevision := TO_NUMBER(SUBSTR(TO_CHAR(vfrevision, 'DDMMYYYY'), 3, 2));
               vperiodo := TO_NUMBER(SUBSTR(TO_CHAR(vfvenci, 'DDMMYYYY'), 5))
                           - TO_NUMBER(SUBSTR(TO_CHAR(vfinicial, 'DDMMYYYY'), 5));
               vaportames := vaportaperiodica;
               vany := TO_NUMBER((SUBSTR((TO_CHAR(vfinicial, 'DDMMYYYY')), 5))) + 1;
               --fecha del siguiente pago
               vfpago := TO_DATE(SUBSTR(TO_CHAR(vfinicial, 'DDMMYYYY'), 1, 4) || TO_CHAR(vany),
                                 'DD/MM/YYYY');

               FOR contador IN 1 .. vperiodo LOOP   --bucle de años
                  IF (vmesinicial = vmesrevision)
                     AND(vany >= vanyrevision) THEN
                     vaportames := f_revalorizacion(vtiporevali, vforma, vaportaperiodica,
                                                    vcreixement, vnmes);
                  END IF;

                  nerror := f_inserta(pssolicit, vnmes, vfpago, vaportames, vany);
                  vany := vany + 1;
                  vfpago := TO_DATE(SUBSTR(TO_CHAR(vfinicial, 'DDMMYYYY'), 1, 4)
                                    || TO_CHAR(vany),
                                    'DD/MM/YYYY');
                  vnmes := vnmes + 1;
               END LOOP;
            END IF;
         END IF;
      END IF;
   END IF;

   IF vforma = 2 THEN
      --******************* primas periódicas semestrales *******************--
      vanyaportainicial := TO_NUMBER(SUBSTR(TO_CHAR(vfefecto, 'DDMMYYYY'), 5));
      nerror := f_inserta(pssolicit, 0, vfefecto, vaportainicial, vanyaportainicial);
      vany := TO_NUMBER(SUBSTR(TO_CHAR(vfinicial, 'DDMMYYYY'), 5));

      IF nerror = 0 THEN
         --PRIMER AÑO
         vmesinicial := TO_NUMBER(SUBSTR(TO_CHAR(vfinicial, 'DDMMYYYY'), 3, 2));
         --el fpago coincide con la fecha de inicio
         vfpago := vfinicial;

         IF vmesinicial <= 6 THEN
            --Si mes<=6 en ese año se hacen dos pagos
            FOR contador IN 1 .. 2 LOOP
               IF nerror = 0 THEN
                  nerror := f_inserta(pssolicit, contador, vfpago, vaportaperiodica, vany);
                  --aumenta 6 meses más
                  vmessig := vmesinicial + 6;
                  vnuevafecha := SUBSTR(TO_CHAR(vfinicial, 'DDMMYYYY'), 1, 2)
                                 || LPAD(TO_CHAR(vmessig), 2, '00') || TO_CHAR(vany);
                  vfpago := TO_DATE(vnuevafecha, 'DD/MM/YYYY');
                  vnmes := 3;
               ELSE
                  EXIT;
               END IF;
            END LOOP;
         ELSE
            --Si mes>6 en ese año sólo se hace un pago
            nerror := f_inserta(pssolicit, 1, vfpago, vaportaperiodica, vany);
            vnmes := 2;
         END IF;

         --RESTO DE AÑOS HASTA FECHA DE VENCIMIENTO
         IF nerror = 0 THEN
            vanyrevision := TO_NUMBER(SUBSTR(TO_CHAR(vfrevision, 'DDMMYYYY'), 5));
            vmesrevision := TO_NUMBER(SUBSTR(TO_CHAR(vfrevision, 'DDMMYYYY'), 3, 2));
            vperiodo := TO_NUMBER(SUBSTR(TO_CHAR(vfvenci, 'DDMMYYYY'), 5))
                        - TO_NUMBER(SUBSTR(TO_CHAR(vfinicial, 'DDMMYYYY'), 5));
            vaportames := vaportaperiodica;
            vany := TO_NUMBER((SUBSTR((TO_CHAR(vfinicial, 'DDMMYYYY')), 5))) + 1;

            FOR contador IN 1 .. vperiodo LOOP   --bucle de años
               FOR cont IN 1 .. 2 LOOP   --para cada año, 2 pagos
                  IF ((cont = 1)
                      AND(vmesinicial > 6))
                     OR((cont = 2)
                        AND(vmesinicial <= 6)) THEN
                     vmessig := vmesinicial + 6;
                     vmessig := f_siguientemes(vmessig);
                  ELSE
                     IF ((cont = 2)
                         AND(vmesinicial > 6))
                        OR((cont = 1)
                           AND(vmesinicial <= 6)) THEN
                        vmessig := vmesinicial;
                     END IF;
                  END IF;

                  IF (vmessig >= vmesrevision)
                     AND(vany >= vanyrevision) THEN   --(VMESREVISION<=6) AND (cont=1) AND (VANY>=VANYREVISION)
                     vaportames := f_revalorizacion(vtiporevali, vforma, vaportaperiodica,
                                                    vcreixement, vnmes);
                  END IF;

                  vnuevafecha := SUBSTR(TO_CHAR(vfinicial, 'DDMMYYYY'), 1, 2)
                                 || LPAD(TO_CHAR(vmessig), 2, '00') || TO_CHAR(vany);
                  vfpago := TO_DATE(vnuevafecha, 'DD/MM/YYYY');
                  nerror := f_inserta(pssolicit, vnmes, vfpago, vaportames, vany);
                  vnmes := vnmes + 1;
               END LOOP;

               vany := vany + 1;
            END LOOP;
         END IF;
      END IF;
   END IF;

   IF vforma = 4 THEN
      --******************* primas periódicas trimestrales *******************--
      vanyaportainicial := TO_NUMBER(SUBSTR(TO_CHAR(vfefecto, 'DDMMYYYY'), 5));
      nerror := f_inserta(pssolicit, 0, vfefecto, vaportainicial, vanyaportainicial);
      vany := TO_NUMBER(SUBSTR(TO_CHAR(vfinicial, 'DDMMYYYY'), 5));
      vfpago := vfinicial;

      IF nerror = 0 THEN
         --PRIMER AÑO
         vmesinicial := TO_NUMBER(SUBSTR(TO_CHAR(vfinicial, 'DDMMYYYY'), 3, 2));
         vmessig := vmesinicial;

         IF vmesinicial <= 3 THEN
            --Si mes<=3 en ese año se hacen cuatro pagos
            FOR contador IN 1 .. 4 LOOP
               IF nerror = 0 THEN
                  nerror := f_inserta(pssolicit, contador, vfpago, vaportaperiodica, vany);

                  IF contador < 4 THEN
                     --aumenta 3 meses más
                     vmessig := vmessig + 3;
                     vnuevafecha := SUBSTR(TO_CHAR(vfinicial, 'DDMMYYYY'), 1, 2)
                                    || LPAD(TO_CHAR(vmessig), 2, '00') || TO_CHAR(vany);
                     vfpago := TO_DATE(vnuevafecha, 'DD/MM/YYYY');
                  END IF;

                  vnmes := 5;
               ELSE
                  EXIT;
               END IF;
            END LOOP;
         END IF;

         IF (vmesinicial > 3)
            AND(vmesinicial <= 6) THEN
            --Si esta entre 3 y 6, en ese año se hacen tres pagas
            FOR contador IN 1 .. 3 LOOP
               IF nerror = 0 THEN
                  nerror := f_inserta(pssolicit, contador, vfpago, vaportaperiodica, vany);

                  IF contador < 3 THEN
                     --aumenta 3 meses más
                     vmessig := vmessig + 3;
                     vnuevafecha := SUBSTR(TO_CHAR(vfinicial, 'DDMMYYYY'), 1, 2)
                                    || LPAD(TO_CHAR(vmessig), 2, '00') || TO_CHAR(vany);
                     vfpago := TO_DATE(vnuevafecha, 'DD/MM/YYYY');
                  END IF;

                  vnmes := 4;
               ELSE
                  EXIT;
               END IF;
            END LOOP;
         END IF;

         IF ((vmesinicial > 6)
             AND(vmesinicial <= 9)) THEN
            --Si esta entre 6 y 9, en ese año se hacen dos pagas
            FOR contador IN 1 .. 2 LOOP
               IF nerror = 0 THEN
                  nerror := f_inserta(pssolicit, contador, vfpago, vaportaperiodica, vany);

                  IF contador < 2 THEN
                     --aumenta 3 meses más
                     vmessig := vmessig + 3;
                     vnuevafecha := SUBSTR(TO_CHAR(vfinicial, 'DDMMYYYY'), 1, 2)
                                    || LPAD(TO_CHAR(vmessig), 2, '00') || TO_CHAR(vany);
                     vfpago := TO_DATE(vnuevafecha, 'DD/MM/YYYY');
                  END IF;

                  vnmes := 3;
               ELSE
                  EXIT;
               END IF;
            END LOOP;
         END IF;

         IF (vmesinicial > 9)
            AND(vmesinicial <= 12) THEN
            --Si esta entre 9 y 12 en ese año sólo se hace un pago
            nerror := f_inserta(pssolicit, 1, vfpago, vaportaperiodica, vany);
            vnmes := 2;
         END IF;

         --RESTO DE AÑOS HASTA FECHA DE VENCIMIENTO
         IF nerror = 0 THEN
            vanyrevision := TO_NUMBER(SUBSTR(TO_CHAR(vfrevision, 'DDMMYYYY'), 5));
            vmesrevision := TO_NUMBER(SUBSTR(TO_CHAR(vfrevision, 'DDMMYYYY'), 3, 2));
            vperiodo := TO_NUMBER(SUBSTR(TO_CHAR(vfvenci, 'DDMMYYYY'), 5))
                        - TO_NUMBER(SUBSTR(TO_CHAR(vfinicial, 'DDMMYYYY'), 5));
            vaportames := vaportaperiodica;
            --NUEVA FECHA
            vnuevafecha := SUBSTR(TO_CHAR(vfinicial, 'DDMMYYYY'), 1, 2)
                           || LPAD(TO_CHAR(vmessig), 2, '00') || TO_CHAR(vany);
            vfechaconv := ADD_MONTHS(TO_DATE(vnuevafecha, 'DDMMYYYY'), 3);
            vmessig := SUBSTR(TO_CHAR(vfechaconv, 'DDMMYYYY'), 3, 2);
            vany := TO_NUMBER(SUBSTR(TO_CHAR(vfechaconv, 'DDMMYYYY'), 5));
            vfpago := vfechaconv;

            FOR contador IN 1 .. vperiodo LOOP   --bucle de años
               FOR cont IN 1 .. 4 LOOP   --para cada año, 4 pagos
                  IF (vmessig >= vmesrevision)
                     AND(vany >= vanyrevision) THEN
                     vaportames := f_revalorizacion(vtiporevali, vforma, vaportaperiodica,
                                                    vcreixement, vnmes);
                  END IF;

                  nerror := f_inserta(pssolicit, vnmes, vfpago, vaportames, vany);

                  IF cont < 4 THEN
                     vnuevafecha := SUBSTR(TO_CHAR(vfinicial, 'DDMMYYYY'), 1, 2)
                                    || LPAD(TO_CHAR(vmessig), 2, '00') || TO_CHAR(vany);
                     vfechaconv := ADD_MONTHS(TO_DATE(vnuevafecha, 'DDMMYYYY'), 3);
                     vmessig := SUBSTR(TO_CHAR(vfechaconv, 'DDMMYYYY'), 3, 2);
                     vany := TO_NUMBER(SUBSTR(TO_CHAR(vfechaconv, 'DDMMYYYY'), 5));
                     vfpago := vfechaconv;
                  END IF;

                  vnmes := vnmes + 1;
               END LOOP;

               vnuevafecha := SUBSTR(TO_CHAR(vfinicial, 'DDMMYYYY'), 1, 2)
                              || LPAD(TO_CHAR(vmessig), 2, '00') || TO_CHAR(vany);
               vfechaconv := ADD_MONTHS(TO_DATE(vnuevafecha, 'DDMMYYYY'), 3);
               vmessig := SUBSTR(TO_CHAR(vfechaconv, 'DDMMYYYY'), 3, 2);
               vany := TO_NUMBER(SUBSTR(TO_CHAR(vfechaconv, 'DDMMYYYY'), 5));
               vfpago := vfechaconv;
            END LOOP;
         END IF;
      END IF;
   END IF;

   IF vforma = 12 THEN
      --******************* primas periódicas mensuales *******************--
      vanyaportainicial := TO_NUMBER(SUBSTR(TO_CHAR(vfefecto, 'DDMMYYYY'), 5));
      nerror := f_inserta(pssolicit, 0, vfefecto, vaportainicial, vanyaportainicial);
      vany := TO_NUMBER(SUBSTR(TO_CHAR(vfinicial, 'DDMMYYYY'), 5));

      IF nerror = 0 THEN
         --PRIMER AÑO
         vmesinicial := TO_NUMBER(SUBSTR(TO_CHAR(vfinicial, 'DDMMYYYY'), 3, 2));
         vmesesfaltan := 13 - vmesinicial;
         vmessig := vmesinicial;

         FOR contador IN 1 .. vmesesfaltan LOOP
            IF nerror = 0 THEN
               vnuevafecha := SUBSTR(TO_CHAR(vfinicial, 'DDMMYYYY'), 1, 2)
                              || LPAD(TO_CHAR(vmessig), 2, '00') || TO_CHAR(vany);
               vfpago := TO_DATE(vnuevafecha, 'DD/MM/YYYY');
               nerror := f_inserta(pssolicit, contador, vfpago, vaportaperiodica, vany);
               vmessig := vmessig + 1;
            ELSE
               EXIT;
            END IF;
         END LOOP;

         vnmes := vmesesfaltan + 1;

         --RESTO DE AÑOS HASTA FECHA DE VENCIMIENTO
         IF nerror = 0 THEN
            vanyrevision := TO_NUMBER(SUBSTR(TO_CHAR(vfrevision, 'DDMMYYYY'), 5));
            vmesrevision := TO_NUMBER(SUBSTR(TO_CHAR(vfrevision, 'DDMMYYYY'), 3, 2));
            vperiodo := TO_NUMBER(SUBSTR(TO_CHAR(vfvenci, 'DDMMYYYY'), 5))
                        - TO_NUMBER(SUBSTR(TO_CHAR(vfinicial, 'DDMMYYYY'), 5));
            vaportames := vaportaperiodica;
            vany := TO_NUMBER((SUBSTR((TO_CHAR(vfinicial, 'DDMMYYYY')), 5))) + 1;

            FOR contador IN 1 .. vperiodo LOOP   --bucle de años
               vmessig := 1;

               FOR cont IN 1 .. 12 LOOP   --para cada año, 12 meses
                  IF (vmessig >= vmesrevision)
                     AND(vany >= vanyrevision) THEN
                     vaportames := f_revalorizacion(vtiporevali, vforma, vaportaperiodica,
                                                    vcreixement, vnmes);
                  END IF;

                  vnuevafecha := SUBSTR(TO_CHAR(vfinicial, 'DDMMYYYY'), 1, 2)
                                 || LPAD(TO_CHAR(vmessig), 2, '00') || TO_CHAR(vany);
                  vfpago := TO_DATE(vnuevafecha, 'DD/MM/YYYY');
                  nerror := f_inserta(pssolicit, vnmes, vfpago, vaportames, vany);
                  vnmes := vnmes + 1;
                  vmessig := vmessig + 1;
               END LOOP;

               vany := vany + 1;
            END LOOP;
         END IF;
      END IF;
   END IF;

   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      -- BUG 21546_108724 - 08/02/2012 - JLTS - Cierre de posibles cursores abiertos
      IF formaspago%ISOPEN THEN
         CLOSE formaspago;
      END IF;

      RETURN -1;
END f_aportacions;

/

  GRANT EXECUTE ON "AXIS"."F_APORTACIONS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_APORTACIONS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_APORTACIONS" TO "PROGRAMADORESCSI";
