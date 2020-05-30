--------------------------------------------------------
--  DDL for Function F_ESTCLAUPARESP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ESTCLAUPARESP" (
	psseguro	IN	NUMBER,
        pnmovimi        IN	NUMBER DEFAULT 1,
	pnriesgo	IN	NUMBER,
	psproduc	IN	NUMBER,
	psalida		IN OUT	NUMBER
)
RETURN NUMBER authid current_user IS
/*****************************************************************
	F_ESTCLAUPARESP
	Mira si un seguro (o riesgo) tiene claúsulas relacionadas
	con preguntas y/o garantias que tengan parámentros.
	En la actualidad este tipo de claúsulas se imprimen de
	forma automática sin dar la posibilidad de que el usuario
	entre los parámetros.
	Retorna 0 / 1
	Utiliza las tabla EST*
******************************************************************
	Se prepara el parámetro psproduct, aunque de momento no se
	utiliza.
******************************************************************
******************************************************************
        S'afegeix el parametre d'entrada pnmovimi.
******************************************************************/
	nerror		number := 0;

	wcramo		number;
	wcmodali	number;
	wctipseg	number;
	wccolect	number;

	CURSOR cur_claurie IS
		SELECT p.sclagen, r.nriesgo, p.sclapro
		FROM   CLAUSUPARA q, CLAUSUPRO p, CLAUSUGAR c, ESTRIESGOS r
		WHERE  p.sclapro = c.sclapro
		AND    q.sclagen = p.sclagen
		AND    c.cramo   = wcramo
		AND    c.cmodali = wcmodali
		AND    c.ctipseg = wctipseg
		AND    c.ccolect = wccolect
		AND    r.nriesgo = pnriesgo
		AND    r.sseguro = psseguro
		UNION
		SELECT p.sclagen, r.nriesgo, p.sclapro
		FROM   CLAUSUPREG c, CLAUSUPARA q, CLAUSUPRO p, ESTRIESGOS r
		WHERE  c.cpregun IN (
				SELECT cpregun
				FROM   ESTPREGUNSEG
				WHERE  sseguro = psseguro
                                and nmovimi=pnmovimi
				UNION
				SELECT cpregun FROM ESTPREGUNGARANSEG
				WHERE sseguro = psseguro
                                and nmovimi=pnmovimi)
		AND    q.sclagen = p.sclagen
		AND    c.sclapro = p.sclapro
		AND    p.cramo   = wcramo
		AND    p.cmodali = wcmodali
		AND    p.ctipseg = wctipseg
		AND    p.ccolect = wccolect
		AND    r.nriesgo = pnriesgo
		AND    r.sseguro = psseguro;

	CURSOR cur_clau IS
		SELECT p.sclagen, r.nriesgo, p.sclapro
		FROM   CLAUSUPARA q, CLAUSUPRO p, CLAUSUGAR c, ESTRIESGOS r
		WHERE  p.sclapro = c.sclapro
		AND    q.sclagen = p.sclagen
		AND    c.cramo   = wcramo
		AND    c.cmodali = wcmodali
		AND    c.ctipseg = wctipseg
		AND    c.ccolect = wccolect
		AND    r.sseguro = psseguro
		UNION
		SELECT p.sclagen, r.nriesgo, p.sclapro
		FROM   CLAUSUPREG c, CLAUSUPARA q, CLAUSUPRO p, ESTRIESGOS r
		WHERE  c.cpregun IN (
				SELECT cpregun
				FROM   ESTPREGUNSEG
				WHERE  sseguro = psseguro
                                and nmovimi=pnmovimi
				UNION
				SELECT cpregun FROM ESTPREGUNGARANSEG
				WHERE sseguro = psseguro
                                and nmovimi=pnmovimi)
		AND    q.sclagen = p.sclagen
		AND    c.sclapro = p.sclapro
		AND    p.cramo   = wcramo
		AND    p.cmodali = wcmodali
		AND    p.ctipseg = wctipseg
		AND    p.ccolect = wccolect
		AND    r.sseguro = psseguro;

	aux_ngar	NUMBER;
	aux_npreg	NUMBER;
	aux_claugar	NUMBER;
	aux_claupreg	NUMBER;
	aux_orden	NUMBER;

BEGIN
  psalida := null;
--
  BEGIN
    SELECT cramo, cmodali, ctipseg, ccolect
    INTO   wcramo, wcmodali, wctipseg, wccolect
    FROM   ESTSEGUROS
    WHERE  sseguro = psseguro;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 100001;	--Algun error
    WHEN OTHERS  THEN
      RETURN 100001;	--Algun error
  END;

  IF pnriesgo IS NOT NULL THEN

    FOR i IN cur_claurie LOOP
      SELECT COUNT(distinct cgarant)
      INTO   aux_ngar
      FROM   CLAUSUGAR
      WHERE  sclapro = i.sclapro;

      SELECT COUNT(distinct cpregun)
      INTO   aux_npreg
      FROM   CLAUSUPREG
      WHERE  sclapro = i.sclapro;

      SELECT COUNT(*) INTO aux_claugar
      FROM   ESTGARANSEG s, CLAUSUGAR g
      WHERE  g.caccion    = decode(s.cgarant, null, 0, 1)
      and    s.sseguro(+) = psseguro
      and    s.nmovimi(+) = pnmovimi
      AND    s.nriesgo(+) = i.nriesgo
      AND    s.cgarant(+) = g.cgarant
      AND    g.ccolect    = wccolect
      AND    g.ctipseg    = wctipseg
      AND    g.cmodali    = wcmodali
      AND    g.cramo      = wcramo
      AND    g.sclapro    = i.sclapro;

      SELECT COUNT(*) INTO aux_claupreg
      FROM   ESTPREGUNSEG s, CLAUSUPREG c
      WHERE  s.cpregun = c.cpregun
      AND s.crespue = c.crespue
      AND s.sseguro = psseguro
      and s.nmovimi = pnmovimi
      AND s.nriesgo = i.nriesgo
      AND c.sclapro = i.sclapro;

      if aux_claupreg = 0 then
         SELECT COUNT(*) INTO aux_claupreg
         FROM   ESTPREGUNGARANSEG s, CLAUSUPREG c
         WHERE  s.cpregun = c.cpregun
         AND s.crespue = c.crespue
         AND s.sseguro = psseguro
         and s.nmovimi = pnmovimi
         AND s.nriesgo = i.nriesgo
         AND c.sclapro = i.sclapro;
      end if;

      IF (aux_claugar + aux_claupreg) > 0 THEN
        IF aux_ngar >= aux_npreg AND (aux_claugar + aux_claupreg) = (aux_ngar + aux_npreg) THEN
          psalida := 1;
          RETURN 0;
        ELSIF aux_ngar < aux_npreg AND (aux_claugar + aux_claupreg) = (aux_ngar + aux_npreg) THEN
          psalida := 1;
          RETURN 0;
        END IF;
      END IF;
    END LOOP;

  ELSE

    FOR i IN cur_clau LOOP
      SELECT COUNT(distinct cgarant)
      INTO   aux_ngar
      FROM   CLAUSUGAR
      WHERE  sclapro = i.sclapro;

      SELECT COUNT(distinct cpregun)
      INTO   aux_npreg
      FROM   CLAUSUPREG
      WHERE  sclapro = i.sclapro;

      SELECT COUNT(*) INTO aux_claugar
      FROM   ESTGARANSEG s, CLAUSUGAR g
      WHERE  g.caccion    = decode(s.cgarant, null, 0, 1)
      and    s.sseguro(+) = psseguro
      and    s.nmovimi(+) = pnmovimi
      AND    s.nriesgo(+) = i.nriesgo
      AND    s.cgarant(+) = g.cgarant
      AND    g.ccolect    = wccolect
      AND    g.ctipseg    = wctipseg
      AND    g.cmodali    = wcmodali
      AND    g.cramo      = wcramo
      AND    g.sclapro    = i.sclapro;

      SELECT COUNT(*) INTO aux_claupreg
      FROM   ESTPREGUNSEG s, CLAUSUPREG c
      WHERE  s.cpregun = c.cpregun
      AND s.crespue = c.crespue
      AND s.sseguro = psseguro
      and s.nmovimi = pnmovimi
      AND s.nriesgo = i.nriesgo
      AND c.sclapro = i.sclapro;

      if aux_claupreg = 0 then
         SELECT COUNT(*) INTO aux_claupreg
         FROM   ESTPREGUNGARANSEG s, CLAUSUPREG c
         WHERE  s.cpregun = c.cpregun
         AND s.crespue = c.crespue
         AND s.sseguro = psseguro
         and s.nmovimi = pnmovimi
         AND s.nriesgo = i.nriesgo
         AND c.sclapro = i.sclapro;
      end if;

      IF (aux_claugar + aux_claupreg) > 0 THEN
        IF aux_ngar >= aux_npreg AND (aux_claugar + aux_claupreg) = (aux_ngar + aux_npreg) THEN
          psalida := 1;
          RETURN 0;
        ELSIF aux_ngar < aux_npreg AND (aux_claugar + aux_claupreg) = (aux_ngar + aux_npreg) THEN
          psalida := 1;
          RETURN 0;
        END IF;
      END IF;
    END LOOP;

  END IF;

  psalida := 0;
  RETURN 0;

END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_ESTCLAUPARESP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ESTCLAUPARESP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ESTCLAUPARESP" TO "PROGRAMADORESCSI";
