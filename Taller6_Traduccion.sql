USE Traduccion
GO

CREATE OR ALTER FUNCTION fTraducir(@Frase NVARCHAR(255), @Idioma VARCHAR(50))
RETURNS @Resultado TABLE (
	Orden INT IDENTITY(1,1),
	[Frases Traducidas] NVARCHAR(255)
)
AS
BEGIN
	DECLARE @IdIdioma INT
	DECLARE @Fragmento NVARCHAR(255)
	DECLARE @Resto NVARCHAR(255)
	DECLARE @Palabra NVARCHAR(255)
	DECLARE @Traducido NVARCHAR(255)
	DECLARE @TraduccionPalabra NVARCHAR(255)
	DECLARE @Pos INT

	SELECT @IdIdioma = Id
	FROM Idioma
	WHERE Idioma = @Idioma

	SET @Frase = LTRIM(RTRIM(@Frase))

	WHILE LEN(@Frase) > 0
	BEGIN
		SET @Pos = CHARINDEX(',', @Frase)

		IF @Pos = 0
		BEGIN
			SET @Fragmento = @Frase
			SET @Frase = ''
		END
		ELSE
		BEGIN
			SET @Fragmento = LTRIM(RTRIM(LEFT(@Frase, @Pos - 1)))
			SET @Frase = LTRIM(SUBSTRING(@Frase, @Pos + 1, LEN(@Frase)))
		END

		SET @Traducido = NULL

		SELECT @Traducido = T.Texto
		FROM Frase F
			JOIN Traduccion T ON T.IdFrase = F.Id
		WHERE F.Texto = @Fragmento
			AND T.IdIdioma = @IdIdioma

		IF @Traducido IS NULL
		BEGIN
			SET @Traducido = ''
			SET @Resto = @Fragmento

			WHILE LEN(@Resto) > 0
			BEGIN
				SET @Pos = CHARINDEX(' ', @Resto)

				IF @Pos = 0
				BEGIN
					SET @Palabra = @Resto
					SET @Resto = ''
				END
				ELSE
				BEGIN
					SET @Palabra = LEFT(@Resto, @Pos - 1)
					SET @Resto = LTRIM(SUBSTRING(@Resto, @Pos + 1, LEN(@Resto)))
				END

				SET @TraduccionPalabra = NULL

				SELECT @TraduccionPalabra = T.Texto
				FROM Frase F
					JOIN Traduccion T ON T.IdFrase = F.Id
				WHERE F.Texto = @Palabra
					AND T.IdIdioma = @IdIdioma

				SET @Traducido = @Traducido + ISNULL(@TraduccionPalabra, @Palabra) + ' '
			END

			SET @Traducido = RTRIM(@Traducido)
		END

		INSERT INTO @Resultado ([Frases Traducidas])
		VALUES (@Traducido)
	END

	RETURN
END
GO

SELECT [Frases Traducidas]
FROM fTraducir('Hola, Buenas Tardes, Cómo te llamas?', 'Inglés')
ORDER BY Orden
GO
