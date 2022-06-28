String getCoinType(String coinType) {
  switch (coinType) {
    case 'ERC20':
      return 'EUSDT';
    case 'Omni':
      return 'USDT';
    case 'TRC20':
      return 'TUSDT';
    case 'BSC':
      return 'USDTBSC';
    default:
      return 'EUSDT';
  }
}