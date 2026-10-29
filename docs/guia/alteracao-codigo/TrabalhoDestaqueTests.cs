using FiapNext.Domain.Entities;
using FluentAssertions;
using Xunit;

namespace FiapNext.Tests.Unit.Domain;

public class TrabalhoDestaqueTests
{
    private static Trabalho CriarTrabalho(decimal nota, decimal relevancia) =>
        new Trabalho(
            "Smart Health Tracker",
            "Sistema inteligente para monitoramento de sinais vitais",
            "HealthTech",
            "https://github.com/fiap/smart-health",
            "https://youtube.com/watch?v=pitch123",
            Guid.NewGuid(),
            nota,
            relevancia);

    [Fact]
    public void EhDestaque_ComNotaERelevanciaAltas_DeveRetornarTrue()
    {
        var trabalho = CriarTrabalho(nota: 9.0m, relevancia: 85m);

        trabalho.EhDestaque().Should().BeTrue();
    }

    [Fact]
    public void EhDestaque_ComNotaAbaixoDoMinimo_DeveRetornarFalse()
    {
        var trabalho = CriarTrabalho(nota: 7.9m, relevancia: 95m);

        trabalho.EhDestaque().Should().BeFalse();
    }

    [Fact]
    public void EhDestaque_ComRelevanciaAbaixoDoMinimo_DeveRetornarFalse()
    {
        var trabalho = CriarTrabalho(nota: 9.5m, relevancia: 69.9m);

        trabalho.EhDestaque().Should().BeFalse();
    }

    [Fact]
    public void EhDestaque_ComValoresNoLimite_DeveRetornarTrue()
    {
        var trabalho = CriarTrabalho(nota: 8.0m, relevancia: 70m);

        trabalho.EhDestaque().Should().BeTrue();
    }
}
