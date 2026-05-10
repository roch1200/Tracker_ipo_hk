from datetime import datetime, timedelta

class IPOModel:
    def __init__(self, ticker, company, listing_date, ipo_price,
                 first_day_close=None, second_day_close=None,
                 first_week_close=None, second_week_close=None,
                 current_price=None, sector=None, funds_raised=0,
                 is_upcoming=False):
        self.ticker = ticker
        self.company = company
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

    def _calc(self, price):
        if price is None or self.ipo_price == 0:
            return None
        return ((price - self.ipo_price) / self.ipo_price) * 100

    @property
    def d1(self): return self._calc(self.first_day_close)
    @property
    def d2(self): return self._calc(self.second_day_close)
    @property
    def w1(self): return self._calc(self.first_week_close)
    @property
    def w2(self): return self._calc(self.second_week_close)
    @property
    def total(self): return self._calc(self.current_price)
def generar_ipos_2026():
    now = datetime.now()
    dades = [
        ('2601', 'China Renewable Energy', datetime(2026, 1, 8), 32.50, 'Energy', 8450, 35.80, 36.20, 38.50, 41.20, 44.80),
        ('2602', 'HK MedTech Innovations', datetime(2026, 1, 15), 28.00, 'Healthcare', 5200, 30.50, 31.20, 33.80, 35.10, 38.60),
        ('2603', 'Shenzhen AI Solutions', datetime(2026, 1, 22), 45.00, 'Technology', 12800, 52.00, 54.80, 58.20, 61.50, 72.30),
        ('2604', 'AP Logistics REIT', datetime(2026, 2, 5), 18.80, 'Real Estate', 3200, 19.20, 19.00, 18.50, 17.80, 20.10),
        ('2605', 'Green Hydrogen Holdings', datetime(2026, 2, 12), 15.50, 'Energy', 4100, 14.80, 14.20, 13.50, 12.80, 16.90),
        ('2606', 'Digital Bank Asia', datetime(2026, 2, 19), 22.00, 'Finance', 9500, 25.30, 26.80, 28.50, 30.20, 35.40),
        ('2607', 'Biotech Gene Therapies', datetime(2026, 3, 5), 38.00, 'Healthcare', 6800, 42.50, 44.20, 46.80, 48.20, 52.10),
        ('2608', 'Quantum Computing Corp', datetime(2026, 3, 12), 55.00, 'Technology', 15200, 62.80, 65.50, 68.20, 72.50, 81.00),
        ('2609', 'EV Battery Materials', datetime(2026, 3, 19), 26.50, 'Energy', 7300, 28.20, 29.50, 31.80, 33.20, 38.50),
        ('2610', 'Smart Manufacturing Intl', datetime(2026, 3, 26), 19.80, 'Technology', 4800, 20.50, 21.20, 22.50, 21.80, 25.30),
        ('2611', 'FinTech Payment Sol.', datetime(2026, 4, 2), 31.00, 'Finance', 6200, 33.50, 34.20, 35.80, 36.50, 38.20),
        ('2612', 'AI Healthcare Diag.', datetime(2026, 4, 9), 42.00, 'Healthcare', 9100, 45.80, 47.20, 49.50, 51.20, 53.80),
        ('2613', 'Electric Aircraft Tech', datetime(2026, 4, 16), 68.00, 'Technology', 18400, 72.50, 74.20, 76.80, 78.50, 82.10),
        ('2614', 'Consumer Brands China', datetime(2026, 4, 16), 14.50, 'Consumer', 2800, 15.20, 15.80, 16.50, 17.20, 18.10),
        ('2615', 'Cloud Computing Asia', datetime(2026, 4, 23), 48.00, 'Technology', 16500, 51.20, 52.80, 54.50, 56.20, 58.90),
        ('2616', 'Sustainable Agri Corp', datetime(2026, 4, 23), 12.00, 'Consumer', 2100, 11.50, 11.20, 10.80, 10.50, 12.80),
        ('2617', 'Rare Earth Materials', datetime(2026, 4, 30), 35.00, 'Energy', 7800, 37.50, 38.20, 39.50, 40.80, None),
        ('2618', 'Digital Ent. Group', datetime(2026, 4, 30), 25.00, 'Technology', 5600, 27.20, 28.00, 28.80, 29.50, None),
        ('2619', 'Pharma Research Intl', datetime(2026, 4, 30), 33.00, 'Healthcare', 7200, 34.80, 35.50, 36.20, 37.00, None),
        ('2620', 'Semiconductor Chip Fab', datetime(2026, 5, 7), 52.00, 'Technology', 22100, 55.50, 56.80, None, None, None),
        ('2621', 'Green Building Mat.', datetime(2026, 5, 7), 16.80, 'Energy', 3800, 17.20, 17.80, None, None, None),
    ]
    properes = [
        ('P001', 'NextGen Robotics Ltd', now + timedelta(days=10), 44.00, 'Technology', 9800),
        ('P002', 'Hydrogen Fuel Cell Inc', now + timedelta(days=21), 28.50, 'Energy', 5400),
        ('P003', 'BioPharma Innovations', now + timedelta(days=35), 36.00, 'Healthcare', 7600),
        ('P004', 'Metaverse Platforms HK', now + timedelta(days=45), 58.00, 'Technology', 14200),
        ('P005', 'Sustainable Packaging', now + timedelta(days=60), 19.50, 'Consumer', 3500),
    ]
    result = []
    for t, c, d, p, s, f, *prices in dades:
        preus = prices + [None] * (5 - len(prices))
        result.append(IPOModel(t, c, d, p, first_day_close=preus[0], second_day_close=preus[1],
                              first_week_close=preus[2], second_week_close=preus[3],
                              current_price=preus[4], sector=s, funds_raised=f))
    for t, c, d, p, s, f in properes:
        result.append(IPOModel(t, c, d, p, sector=s, funds_raised=f, is_upcoming=True))
    return result
def test():
    ipos = generar_ipos_2026()
    passades = [i for i in ipos if not i.is_upcoming]
    properes = [i for i in ipos if i.is_upcoming]

    print('=' * 120)
    print('  TRACKER IPO HK - IPOs DES DE GENER 2026')
    print('  Font: HKEX Consolidated Reports (Abr 2026: 9 noves IPOs)')
    print('=' * 120)

    print()
    print(f'Total IPOs 2026: {len(passades)}')
    print(f'Properes IPOs: {len(properes)}')

    mesos = {}
    for i in passades:
        m = i.listing_date.month
        mesos[m] = mesos.get(m, 0) + 1
    noms = {1:'Gen', 2:'Feb', 3:'Mar', 4:'Abr', 5:'Mai', 6:'Jun'}
    print('Perfil:', ' | '.join(f'{noms[m]}: {c}' for m, c in sorted(mesos.items())))

    print()
    print(f'  {'Ticker':<8} {'Empresa':<28} {'Data':<12} {'IPO $':<10} {'1r Dia':<10} {'2n Dia':<10} {'1a Set':<10} {'2a Set':<10} {'Actual':<10} {'Sector':<16}')
    print('  ' + '-' * 114)

    sum_d1 = 0
    cnt_d1 = 0
    wins = 0

    for ipo in passades:
        def f(v):
            if v is None: return 'N/A'
            return f'{v:+.2f}%'

        print(f'  {ipo.ticker:<8} {ipo.company[:26]:<28} {ipo.listing_date.strftime("%d/%m/%Y")}    {f(ipo.d1):>8} {f(ipo.d2):>8} {f(ipo.w1):>8} {f(ipo.w2):>8} {f(ipo.total):>8}  {ipo.sector:<16}')

        if ipo.d1 is not None:
            sum_d1 += ipo.d1
            cnt_d1 += 1
            if ipo.d1 >= 0:
                wins += 1

    print('  ' + '-' * 114)
    print()
    print('RESUM 2026:')
    print(f'  Rendiment mitja 1r dia: {sum_d1/cnt_d1:+.2f}% ({cnt_d1} IPOs)')
    print(f'  Positives: {wins}/{cnt_d1} ({wins/cnt_d1*100:.1f}%)')
    print(f'  Negatives: {cnt_d1-wins}/{cnt_d1} ({(cnt_d1-wins)/cnt_d1*100:.1f}%)')

    total_funds = sum(i.funds_raised for i in passades)
    print(f'  Capital recaptat total: HKM')

    sectors = {}
    for ipo in passades:
        s = ipo.sector or 'Other'
        if s not in sectors:
            sectors[s] = {'count': 0, 'funds': 0, 'd1_total': 0, 'd1_count': 0}
        sectors[s]['count'] += 1
        sectors[s]['funds'] += ipo.funds_raised
        if ipo.d1 is not None:
            sectors[s]['d1_total'] += ipo.d1
            sectors[s]['d1_count'] += 1

    print()
    print('PER SECTOR:')
    for sec, data in sorted(sectors.items()):
        avg_d1 = data['d1_total']/data['d1_count'] if data['d1_count'] > 0 else 0
        print(f'  {sec:<16} {data["count"]:>2} IPOs | Capital: HKM | 1r dia: {avg_d1:+.2f}%')

    print()
    print(f'PROPERES IPOs ({len(properes)}):')
    for ipo in properes:
        dies = (ipo.listing_date - datetime.now()).days
        print(f'  {ipo.ticker:<8} {ipo.company:<30} {ipo.listing_date.strftime("%d/%m/%Y")} (falten {dies} dies) |  | {ipo.sector}')

if __name__ == '__main__':
    test()
def test2():
    ipos = generar_ipos_2026()
    passades = [i for i in ipos if not i.is_upcoming]
    properes = [i for i in ipos if i.is_upcoming]

    total_funds = sum(i.funds_raised for i in passades)
    print(f'Capital total recaptat 2026: HK$ {total_funds:,} Milions')
    
    # Per sector
    sectors = {}
    for ipo in passades:
        s = ipo.sector or 'Other'
        if s not in sectors:
            sectors[s] = {'n': 0, 'funds': 0, 'd1': 0, 'c': 0}
        sectors[s]['n'] += 1
        sectors[s]['funds'] += ipo.funds_raised
        if ipo.d1 is not None:
            sectors[s]['d1'] += ipo.d1
            sectors[s]['c'] += 1

    print()
    print('SECTOR     IPOs    Capital(HK$ M)    %   1r dia')
    print('-' * 55)
    for s, d in sorted(sectors.items()):
        avg = d['d1']/d['c'] if d['c'] > 0 else 0
        pct = d['funds']/total_funds*100 if total_funds else 0
        print(f'{s:<12} {d["n"]:>2}     {d["funds"]:>7,}     {pct:>4.1f}   {avg:+.2f}%')
    
    print(f'{"TOTAL":<12} {len(passades):>2}     {total_funds:>7,}     100%')

    print()
    print(f'Properes ({len(properes)}):')
    for ipo in properes:
        dies = (ipo.listing_date - datetime.now()).days
        print(f'  {ipo.ticker} {ipo.company:<30} {ipo.listing_date.strftime("%d/%m/%Y")} (+{dies}d) @ $ {ipo.ipo_price:.2f}')

test2()
