## MVP

### Główny problem

Mały i średni deweloper musi regularnie przygotowywać oraz udostępniać dane cenowe zgodne z nowymi wymogami ustawy deweloperskiej, w szczególności z art. 19b dotyczącym codziennego przekazywania danych o cenach i innymi obowiązkami związanymi z jawnością cen.

Ręczne prowadzenie cenników, historii zmian, plików XML i publikacji na stronie WWW jest czasochłonne, podatne na błędy i trudne do udokumentowania w razie kontroli.

### Najmniejszy zestaw funkcjonalności

- Dodawanie inwestycji w panelu administracyjnym.
- Dodawanie lokali ręcznie.
- Import lokali i cen z pliku Excel / CSV.
- Zarządzanie podstawowymi danymi lokalu:
  - numer lokalu,
  - metraż,
  - liczba pokoi,
  - piętro,
  - status,
  - cena,
  - cena za m²,
  - data obowiązywania ceny.
- Przechowywanie historii zmian cen dla każdego lokalu.
- Generowanie aktualnego pliku XML z cennikiem lokali.
- Udostępnienie pliku XML pod stałym adresem URL.
- Przechowywanie i utrzymywanie dostępu do danych zgodnie z wymaganym okresem.
- Prosty embed kod do osadzenia aktualnej tabeli cen na stronie dewelopera.
- Publiczna tabela lokali z cenami, historią zmian i podstawowym filtrowaniem.
- Panel walidacji zgodności, który pokazuje, czy oferta zawiera wymagane dane.
- Dziennik zmian: kto, kiedy i co zmienił.
- Podstawowy formularz leadowy przy lokalu, np. "Zapytaj o lokal".
- Podstawowe statystyki:
  - liczba wyświetleń tabeli,
  - liczba kliknięć w lokal,
  - liczba wysłanych zapytań.
- System kont użytkowników dla dewelopera i osób obsługujących inwestycję.

### Co NIE wchodzi w zakres MVP

- Publiczne API dla zewnętrznych systemów.
- Integracje z CRM, ERP, Otodom, OLX, stronami deweloperskimi i innymi portalami.
- Plugin WordPress.
- Gotowa strona inwestycji generowana przez system.
- Aplikacje mobilne.
- Marketplace mieszkań.
- Płatności online.
- Moduł koszyka lub rezerwacji lokalu.
- Zaawansowany CRM sprzedażowy.
- Automatyczne generowanie interaktywnej mapy z płaskiego obrazu inwestycji.
- Zaawansowany monitoring konkurencji.
- Rozbudowane pakiety enterprise, integracje indywidualne i pełna automatyzacja wdrożenia.
- Wewnętrzny AI chat załadowany wiedzą o tej ustawie i wymaganiach

### Kryteria sukcesu

- System poprawnie publikuje aktualne ceny lokali i historię zmian.
- System generuje poprawny plik XML i udostępnia go pod stałym adresem URL.
- Deweloper może samodzielnie dodać inwestycję i lokale bez pomocy programisty.
- Deweloper może zaimportować lokale z Excela / CSV.
- Tabela cen może zostać osadzona na stronie klienta przez prosty embed kod.
- Użytkownik widzi, które dane są kompletne, a które wymagają poprawy.
- Każda zmiana ceny jest zapisana w historii i możliwa do odtwórczego sprawdzenia.
- Pierwszy klient może uruchomić zgodną publikację cen dla jednej inwestycji bez indywidualnego developmentu.

## Krótki opis produktu

**Developer Partner** to SaaS dla małych i średnich deweloperów, który pomaga spełnić obowiązki związane z jawnością cen mieszkań. System umożliwia zarządzanie inwestycjami, lokalami, cennikami, historią zmian cen, generowaniem pliku XML oraz publikacją aktualnej tabeli cen na stronie internetowej dewelopera.

W pierwszej wersji produkt skupia się na najważniejszym problemie: **poprawnym publikowaniu cen, historii zmian i pliku XML zgodnie z wymaganiami ustawy**.

Dodatkowo MVP zawiera pierwsze elementy przewagi konkurencyjnej:

- prosty formularz leadowy,
- podstawowe statystyki zainteresowania lokalami,
- panel sprawdzający kompletność danych.

Docelowo system może rozwinąć się w pełne centrum zarządzania ofertą dewelopera:

- gotowa strona inwestycji,
- plugin WordPress,
- API,
- integracje z portalami ogłoszeniowymi,
- moduł leadów,
- porównywarka mieszkań,
- analiza cen,
- interaktywna mapa inwestycji.

## Model biznesowy

Podstawowy model rozliczenia:

- jednorazowe wdrożenie,
- abonament za inwestycję.

Docelowe rozszerzenia pakietów:

- wyższy pakiet z gotową stroną inwestycji,
- integracje z portalami typu Otodom,
- moduł kosztów inwestycji,
- moduł koszyka generującego leady, bez płatności online,
- integracje API,
- rozbudowane raportowanie i analityka.
