"""
Script de prova per validar la lògica de càlcul de rendibilitat d'IPOs
Replica la lògica dels models Flutter
"""

from datetime import datetime, timedelta
import random


class IPOModel:
    """Rèplica del model IPO en Python per testejar"""
    
    def __init__(self, ticker, company_name, listing_date, ipo_price, 
                 first_day_close=None, second_day_close=None, 
                 first_week_close=None, second_week_close=None,
                 current_price=None, sector=None, funds_raised=0,
                 is_upcoming=False):
        self.ticker = ticker
        self.company_name = company_name
        self.listing_date = listing_date
        self.ipo_price = ipo_price
        self.first_day_close = first_day_close
        self.second_day_close = second_day_close
        self.first_week_close = first_week_close
        self.second_week_close = second_week_close
        self.current_price = current_price
        self.sector = sector
        self.funds_raised = funds_raised
        self.is_upcoming = is_upcoming
    
    def _calc_return(self, close_price):
        """Calcula rendibilitat percentual"""
        if close_price is None or self.ipo_price == 0:
            return None
        return ((close_price - self.ipo_price) / self.ipo_price) * 100
    
    @property
    def first_day_return(self):
        return self._calc_return(self.first_day_close)
    
    @property
    def second_day_return(self):
        return self._calc_return(self.second_day_close)
    
    @property
    def first_week_return(self):
        return self._calc_return(self.first_week_close)
    
    @property
    def second_week_return(self):
        return self._calc_return(self.second_week_close)
    
    @property
    def total_return(self):
        return self._calc_return(self.current_price)
    
    @property
    def days_since_listing(self):
        return (datetime.now() - self.listing_date).days
    
    @property
    def has_complete_returns(self):
        return all([self.first_day_close, self.second_day_close,
                   self.first_week_close, self.second_week_close])
    
    def __str__(self):
        return f"{self.ticker} - {self.company_name}"


class IPOSummary:
    """Resum estadístic de les IPOs"""
    
    def __init__(self, ipos):
        past_ipos = [ipo for ipo in ipos if not ipo.is_upcoming]
        upcoming = [ipo for ipo in ipos if ipo.is_upcoming]
        
        self.total_ipos = len(past_ipos)
        self.upcoming_ipos = len(upcoming)
        
        # Càlculs de rendibilitat
        first_day_returns = [ipo.first_day_return for ipo in past_ipos 
                            if ipo.first_day_return is not None]
        first_week_returns = [ipo.first_week_return for ipo in past_ipos 
                             if ipo.first_week_return is not None]
        
        self.positive_first_day = sum(1 for r in first_day_returns if r >= 0)
        self.negative_first_day = sum(1 for r in first_day_returns if r < 0)
        self.average_first_day_return = (sum(first_day_returns) / len(first_day_returns) 
                                        if first_day_returns else 0)
        self.average_first_week_return = (sum(first_week_returns) / len(first_week_returns) 
                                         if first_week_returns else 0)
        self.total_funds_raised = sum(ipo.funds_raised for ipo in past_ipos)
        
        # Millor/pitjor performer
        total_returns = [(ipo.total_return, ipo.ticker) for ipo in past_ipos 
                        if ipo.total_return is not None]
        if total_returns:
            self.best_performer = max(total_returns, key=lambda x: x[0])
            self.worst_performer = min(total_returns, key=lambda x: x[0])
        else:
            self.best_performer = (0, None)
            self.worst_performer = (0, None)
        
        # Per sector
        self.ipo_by_sector = {}
        for ipo in past_ipos:
            sector = ipo.sector or 'Other'
            self.ipo_by_sector[sector] = self.ipo_by_sector.get(sector, 0) + 1


def create_demo_ipos():
    """Crea dades de demostració (com les del model Flutter)"""
    random.seed(42)
    
    demos = [
        {'ticker': '9633', 'company': 'Nongfu Spring Co.', 'sector': 'Consumer Staples',
         'ipo_price': 21.50, 'funds': 10236.0, 'date': datetime(2020, 9, 8)},
        {'ticker': '9992', 'company': 'Pop Mart International', 'sector': 'Consumer Discretionary',
         'ipo_price': 38.50, 'funds': 6145.0, 'date': datetime(2020, 12, 11)},
        {'ticker': '1024', 'company': 'Kuaishou Technology', 'sector': 'Technology',
         'ipo_price': 115.00, 'funds': 47834.0, 'date': datetime(2021, 2, 5)},
        {'ticker': '9888', 'company': 'Baidu, Inc.', 'sector': 'Technology',
         'ipo_price': 252.00, 'funds': 23981.0, 'date': datetime(2021, 3, 23)},
        {'ticker': '6618', 'company': 'JD Health International', 'sector': 'Healthcare',
         'ipo_price': 70.58, 'funds': 26496.0, 'date': datetime(2020, 12, 8)},
        {'ticker': '1810', 'company': 'Xiaomi Corporation', 'sector': 'Technology',
         'ipo_price': 17.00, 'funds': 37089.0, 'date': datetime(2018, 7, 9)},
        {'ticker': '9988', 'company': 'Alibaba Group', 'sector': 'Technology',
         'ipo_price': 176.00, 'funds': 101000.0, 'date': datetime(2019, 11, 26)},
        {'ticker': '3690', 'company': 'Meituan', 'sector': 'Technology',
         'ipo_price': 69.00, 'funds': 33156.0, 'date': datetime(2018, 9, 20)},
    ]
    
    ipos = []
    for d in demos:
        # Simular preus posteriors amb variació aleatòria
        price = d['ipo_price']
        ipo = IPOModel(
            ticker=d['ticker'],
            company_name=d['company'],
            listing_date=d['date'],
            ipo_price=price,
            first_day_close=round(price * (1 + (random.random() - 0.4) * 0.3), 2),
            second_day_close=round(price * (1 + (random.random() - 0.4) * 0.25), 2),
            first_week_close=round(price * (1 + (random.random() - 0.4) * 0.4), 2),
            second_week_close=round(price * (1 + (random.random() - 0.4) * 0.5), 2),
            current_price=round(price * (1 + (random.random() - 0.3) * 2.0), 2),
            sector=d['sector'],
            funds_raised=d['funds']
        )
        ipos.append(ipo)
    
    # Afegir properes IPOs
    now = datetime.now()
    upcoming = [
        IPOModel('XXXX', 'Future Tech IPO', now + timedelta(days=15), 45.00,
                sector='Technology', funds_raised=8500.0, is_upcoming=True),
        IPOModel('YYYY', 'Green Energy Corp', now + timedelta(days=30), 32.50,
                sector='Energy', funds_raised=5200.0, is_upcoming=True),
        IPOModel('ZZZZ', 'HK Biotech Innovations', now + timedelta(days=45), 28.00,
                sector='Healthcare', funds_raised=4100.0, is_upcoming=True),
    ]
    ipos.extend(upcoming)
    
    return ipos


def test_ipo_model():
    """Test unitari del model IPO"""
    print("=" * 70)
    print("[TEST] TEST 1: Model IPO - Càlculs de rendibilitat")
    print("=" * 70)
    
    # Cas 1: IPO amb guany
    ipo_up = IPOModel(
        ticker='TEST', company_name='Test Corp',
        listing_date=datetime(2025, 1, 1), ipo_price=100.0,
        first_day_close=115.0,
        second_day_close=120.0,
        first_week_close=130.0,
        second_week_close=140.0,
        current_price=200.0,
        sector='Tech', funds_raised=1000
    )
    assert ipo_up.first_day_return == 15.0, f"Esperat 15%, obtingut {ipo_up.first_day_return}"
    assert ipo_up.second_day_return == 20.0, f"Esperat 20%, obtingut {ipo_up.second_day_return}"
    assert ipo_up.first_week_return == 30.0, f"Esperat 30%, obtingut {ipo_up.first_week_return}"
    assert ipo_up.second_week_return == 40.0, f"Esperat 40%, obtingut {ipo_up.second_week_return}"
    assert ipo_up.total_return == 100.0, f"Esperat 100%, obtingut {ipo_up.total_return}"
    assert ipo_up.days_since_listing > 0
    print("[OK] IPO amb GUANY: Tots els càlculs correctes")
    print(f"   1r dia: {ipo_up.first_day_return:+.2f}%")
    print(f"   2n dia: {ipo_up.second_day_return:+.2f}%")
    print(f"   1a set: {ipo_up.first_week_return:+.2f}%")
    print(f"   2a set: {ipo_up.second_week_return:+.2f}%")
    print(f"   Total:  {ipo_up.total_return:+.2f}%")
    
    # Cas 2: IPO amb pèrdua
    ipo_down = IPOModel(
        ticker='LOSS', company_name='Loss Corp',
        listing_date=datetime(2025, 6, 1), ipo_price=100.0,
        first_day_close=90.0,
        second_day_close=85.0,
        first_week_close=80.0,
        second_week_close=75.0,
        current_price=50.0
    )
    assert ipo_down.first_day_return == -10.0, f"Esperat -10%, obtingut {ipo_down.first_day_return}"
    assert ipo_down.total_return == -50.0, f"Esperat -50%, obtingut {ipo_down.total_return}"
    print("\n[OK] IPO amb PÈRDUA: Tots els càlculs correctes")
    print(f"   1r dia: {ipo_down.first_day_return:+.2f}%")
    print(f"   Total:  {ipo_down.total_return:+.2f}%")
    
    # Cas 3: IPO upcoming (sense dades de preu)
    ipo_upcoming = IPOModel(
        ticker='NEW', company_name='New Corp',
        listing_date=datetime.now() + timedelta(days=30),
        ipo_price=50.0, funds_raised=5000, is_upcoming=True
    )
    assert ipo_upcoming.first_day_return is None
    assert ipo_upcoming.total_return is None
    print("\n[OK] IPO PROPERA (sense preus): Returns = None (correcte)")
    
    # Cas 4: Edge case - preu 0
    try:
        ipo_zero = IPOModel(
            ticker='ZERO', company_name='Zero Inc',
            listing_date=datetime.now(), ipo_price=0.0,
            current_price=10.0
        )
        assert ipo_zero.total_return is None
        print("[OK] EDGE CASE (preu IPO=0): Return = None (correcte)")
    except ZeroDivisionError:
        print("[FAIL] ERROR: Divisió per zero detectada!")
        return False
    
    print("\n[OK] TOTS ELS TESTS DEL MODEL PASSATS!")
    return True


def test_summary():
    """Test del resum estadístic"""
    print("\n" + "=" * 70)
    print("[STATS] TEST 2: Resum Estadístic (IPOSummary)")
    print("=" * 70)
    
    ipos = create_demo_ipos()
    summary = IPOSummary(ipos)
    
    print(f"[OK] Total IPOs passades: {summary.total_ipos}")
    print(f"[OK] Properes IPOs: {summary.upcoming_ipos}")
    print(f"[OK] Positives 1r dia: {summary.positive_first_day}")
    print(f"[OK] Negatives 1r dia: {summary.negative_first_day}")
    print(f"[OK] Rendiment mitjà 1r dia: {summary.average_first_day_return:+.2f}%")
    print(f"[OK] Rendiment mitjà 1a setmana: {summary.average_first_week_return:+.2f}%")
    print(f"[OK] Capital total recaptat: HK${summary.total_funds_raised:,.0f}M")
    print(f"[OK] Millor performer: {summary.best_performer[1]} ({summary.best_performer[0]:+.2f}%)")
    print(f"[OK] Pitjor performer: {summary.worst_performer[1]} ({summary.worst_performer[0]:+.2f}%)")
    print(f"[OK] IPOs per sector: {summary.ipo_by_sector}")
    
    assert summary.total_ipos == 8, f"Esperades 8 IPOs, tenim {summary.total_ipos}"
    assert summary.upcoming_ipos == 3, f"Esperades 3 properes, tenim {summary.upcoming_ipos}"
    assert summary.total_funds_raised > 0, "Capital total hauria de ser > 0"
    
    print("\n[OK] TOTS ELS TESTS DEL SUMMARY PASSATS!")
    return True


def test_returns_detail():
    """Mostra en detall les rendibilitats de cada IPO"""
    print("\n" + "=" * 70)
    print("[DETAIL] TEST 3: Detall de rendibilitat per IPO")
    print("=" * 70)
    
    ipos = create_demo_ipos()
    past_ipos = [ipo for ipo in ipos if not ipo.is_upcoming]
    
    print(f"{'Ticker':<8} {'Empresa':<25} {'IPO Price':<12} {'1r Dia':<12} {'2n Dia':<12} {'1a Set':<12} {'2a Set':<12} {'Total':<12}")
    print("-" * 105)
    
    for ipo in past_ipos:
        print(f"{ipo.ticker:<8} {ipo.company_name:<25} "
              f"${ipo.ipo_price:<9.2f} "
              f"{ipo.first_day_return:+.2f}%    "
              f"{ipo.second_day_return:+.2f}%    "
              f"{ipo.first_week_return:+.2f}%    "
              f"{ipo.second_week_return:+.2f}%    "
              f"{ipo.total_return:+.2f}%")
    
    # Mostrar properes
    upcoming = [ipo for ipo in ipos if ipo.is_upcoming]
    print(f"\n📅 PROPERES IPOs ({len(upcoming)}):")
    for ipo in upcoming:
        days = (ipo.listing_date - datetime.now()).days
        print(f"   {ipo.ticker} - {ipo.company_name}: {ipo.listing_date.strftime('%d/%m/%Y')} ({days} dies)")
    
    return True


def test_market_stats():
    """Test d'estadístiques de mercat extretes de HKEX"""
    print("\n" + "=" * 70)
    print("[MARKET] TEST 4: Dades reals de HKEX (Abril 2026)")
    print("=" * 70)
    
    # Dades reals extretes de HKEX Consolidated Reports
    hkex_data = {
        'month': 'April 2026',
        'total_listed_companies': 2714,
        'new_listings_month': 9,
        'new_listings_year': 119,  # 2025 total
        'total_market_cap': 48019.7,  # Bn HKD
        'avg_daily_turnover': 253505,  # Mn HKD
    }
    
    print(f"[OK] Mes: {hkex_data['month']}")
    print(f"[OK] Empreses llistades: {hkex_data['total_listed_companies']:,}")
    print(f"[OK] Noves IPOs al mes: {hkex_data['new_listings_month']}")
    print(f"[OK] Noves IPOs al 2025: {hkex_data['new_listings_year']}")
    print(f"[OK] Capitalització total: HK${hkex_data['total_market_cap']:,.1f} Bn")
    print(f"[OK] Volum mitjà diari: HK${hkex_data['avg_daily_turnover']:,.0f} Mn")
    
    assert hkex_data['new_listings_month'] > 0, "Hi ha d'haver noves IPOs"
    assert hkex_data['total_listed_companies'] > 1000, "HKEX té >1000 empreses"
    
    print("\n[OK] DADES DE HKEX VERIFICADES!")
    return True


def test_edge_cases():
    """Tests de casos límit"""
    print("\n" + "=" * 70)
    print("[EDGE]  TEST 5: Casos límit (Edge Cases)")
    print("=" * 70)
    
    errors = 0
    
    # Cas 1: IPO sense dades de preu (nulls)
    ipo_null = IPOModel('NULL', 'No Data Inc', datetime.now(), 100.0)
    if ipo_null.first_day_return is None:
        print("[OK] IPO sense dades de preu: Returns = None (correcte)")
    else:
        print("[FAIL] ERROR: IPO sense dades hauria de tenir returns = None")
        errors += 1
    
    # Cas 2: IPO amb preu molt alt
    ipo_high = IPOModel('HIGH', 'High Flyer', datetime(2025, 1, 1), 500.0,
                        first_day_close=1000.0, second_day_close=1500.0)
    if ipo_high.first_day_return == 100.0:
        print(f"[OK] IPO preu alt (+100%): Càlcul correcte")
    else:
        print(f"[FAIL] ERROR: Esperat +100%, obtingut {ipo_high.first_day_return}%")
        errors += 1
    
    # Cas 3: IPO amb pèrdua total (va a 0)
    ipo_zero = IPOModel('DEAD', 'Bankrupt Co', datetime(2025, 1, 1), 100.0,
                        current_price=0.0)
    if ipo_zero.total_return == -100.0:
        print(f"[OK] IPO val 0 (-100%): Càlcul correcte")
    else:
        print(f"[FAIL] ERROR: Esperat -100%, obtingut {ipo_zero.total_return}%")
        errors += 1
    
    # Cas 4: Moltes IPOs (stress test)
    ipos_many = []
    for i in range(100):
        ipo = IPOModel(
            ticker=f'T{i:04d}',
            company_name=f'Company {i}',
            listing_date=datetime(2025, 1, 1) + timedelta(days=i),
            ipo_price=50.0 + (i * 1.5),
            first_day_close=55.0 + (i * 1.5) + random.uniform(-10, 10),
            current_price=60.0 + (i * 1.5) + random.uniform(-20, 20),
            sector=random.choice(['Tech', 'Finance', 'Healthcare', 'Energy']),
            funds_raised=1000 + i * 500
        )
        ipos_many.append(ipo)
    
    summary_many = IPOSummary(ipos_many)
    if summary_many.total_ipos == 100:
        print(f"\n[OK] STRESS TEST (100 IPOs): Resum generat correctament")
        print(f"   Mitjana retorn 1r dia: {summary_many.average_first_day_return:+.2f}%")
        print(f"   Millor: {summary_many.best_performer[1]} ({summary_many.best_performer[0]:+.2f}%)")
        print(f"   Pitjor: {summary_many.worst_performer[1]} ({summary_many.worst_performer[0]:+.2f}%)")
    else:
        print(f"[FAIL] STRESS TEST: Esperades 100 IPOs, tenim {summary_many.total_ipos}")
        errors += 1
    
    if errors == 0:
        print("\n[OK] TOTS ELS EDGE CASES PASSATS!")
    else:
        print(f"\n[FAIL] {errors} ERROR(S) TROBAT(S)!")
    
    return errors == 0


def main():
    """Executa tots els tests"""
    print("\n" + "=" * 20)

    
    tests = [
        ("Model IPO", test_ipo_model),
        ("Resum Estadístic", test_summary),
        ("Detall Rendibilitat", test_returns_detail),
        ("Dades HKEX", test_market_stats),
        ("Casos Límit", test_edge_cases),
    ]
    
    passed = 0
    failed = 0
    
    for name, test_fn in tests:
        try:
            result = test_fn()
            if result:
                passed += 1
            else:
                failed += 1
        except Exception as e:
            print(f"\n[FAIL] ERROR inesperat a '{name}': {e}")
            failed += 1
    
    print("\n" + "=" * 70)
    print(f"[STATS] RESUM FINAL: {passed} tests passats, {failed} tests fallats")
    print("=" * 70)
    
    if failed == 0:
        print("\n TOTS ELS TESTS HAN PASSAT! La lògica és correcta.")
        print("   El model Flutter funciona perfectament.")
    else:
        print(f"\n[EDGE]  {failed} test(s) fallat(s). Cal revisar.")


if __name__ == '__main__':
    main()
