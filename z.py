from datetime import datetime, timedelta

class IPOModel:
    def __init__(self, ticker, company, listing_date, ipo_price, first_day_close=None, second_day_close=None, first_week_close=None, second_week_close=None, current_price=None, sector=None, funds_raised=0, is_upcoming=False):
        self.ticker=ticker; self.company=company; self.listing_date=listing_date; self.ipo_price=ipo_price
        self.first_day_close=first_day_close; self.second_day_close=second_day_close
        self.first_week_close=first_week_close; self.second_week_close=second_week_close
        self.current_price=current_price; self.sector=sector; self.funds_raised=funds_raised
        self.is_upcoming=is_upcoming
    def _calc(self, p):
        if p is None or self.ipo_price==0:
            return None
        return ((p - self.ipo_price) / self.ipo_price) * 100
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
