import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../themes/app_colors.dart';

class TradingViewChart extends StatefulWidget {
  final String symbol;
  final String interval;
  final String theme;

  const TradingViewChart({
    super.key,
    this.symbol = 'FOREXCOM:XAUUSD',
    this.interval = '300',
    this.theme = 'dark',
  });

  @override
  State<TradingViewChart> createState() => _TradingViewChartState();
}

class _TradingViewChartState extends State<TradingViewChart> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            print('TradingViewChart loading progress: $progress%');
          },
          onPageStarted: (String url) {
            print('TradingViewChart page started: $url');
          },
          onPageFinished: (String url) {
            print('TradingViewChart page finished: $url');
          },
          onWebResourceError: (WebResourceError error) {
            print('TradingViewChart error: ${error.description}');
          },
        ),
      )
      ..loadHtmlString(_getTradingViewHTML());
    print(
      'Initialized TradingViewChart: symbol=${widget.symbol}, interval=${widget.interval}, theme=${widget.theme}',
    );
  }

  @override
  void didUpdateWidget(covariant TradingViewChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.symbol != oldWidget.symbol ||
        widget.interval != oldWidget.interval ||
        widget.theme != oldWidget.theme) {
      _controller.loadHtmlString(_getTradingViewHTML());
      print(
        'Updated TradingViewChart: symbol=${widget.symbol}, interval=${widget.interval}, theme=${widget.theme}',
      );
    }
  }

  String _getTradingViewHTML() {
    // Determine if using dark theme based on widget.theme parameter
    final bool isDarkMode = widget.theme == 'dark';

    // Use AppColors directly - convert Color to hex string
    final backgroundColor = isDarkMode
        ? '1E1E1E' // Dark background
        : AppColors.screenBackground.value
        .toRadixString(16)
        .padLeft(8, '0')
        .substring(2);

    final textColor = isDarkMode
        ? 'CCCCCC' // Light gray text for dark mode
        : AppColors.primaryText.value
        .toRadixString(16)
        .padLeft(8, '0')
        .substring(2);

    final gridColor = isDarkMode
        ? '2A2A2A' // Dark gray grid
        : AppColors.border.value
        .toRadixString(16)
        .padLeft(8, '0')
        .substring(2);

    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>TradingView Chart</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        html, body {
            height: 100%;
            width: 100%;
            margin: 0;
            padding: 0;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
            overflow: hidden;
            background-color: #$backgroundColor;
        }
        
        .tradingview-widget-container {
            height: 100%;
            width: 100%;
            display: flex;
            flex-direction: column;
            position: relative;
        }
        
        .tradingview-widget-container__widget {
            flex: 1;
            width: 100%;
            height: 100%;
            position: relative;
            min-height: 400px;
        }
        
        /* Loading indicator */
        .loading {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            color: #$textColor;
            font-size: 14px;
            display: none;
        }
        
        /* Responsive adjustments */
        @media (max-width: 768px) {
            .tradingview-widget-container__widget {
                min-height: 350px;
            }
        }
        
        @media (max-width: 600px) {
            .tradingview-widget-container__widget {
                min-height: 300px;
            }
        }
        
        @media (max-width: 400px) {
            .tradingview-widget-container__widget {
                min-height: 280px;
            }
        }
    </style>
</head>
<body>
    <div class="tradingview-widget-container">
        <div class="tradingview-widget-container__widget" id="chart-container">
            <div class="loading" id="loading">Loading chart...</div>
        </div>
    </div>

    <script type="text/javascript">
        let chartLoaded = false;
        
        function loadTradingViewWidget() {
            if (chartLoaded) {
                console.log('Chart already loaded, skipping...');
                return;
            }
            
            const loadingEl = document.getElementById('loading');
            if (loadingEl) {
                loadingEl.style.display = 'block';
            }
            
            // Get container dimensions
            const container = document.getElementById('chart-container');
            const containerWidth = container.offsetWidth || window.innerWidth;
            const containerHeight = container.offsetHeight || window.innerHeight;
            
            console.log('Container dimensions:', containerWidth, 'x', containerHeight);
            
            const config = {
                "allow_symbol_change": false,
                "calendar": false,
                "details": false,
                "hide_side_toolbar": true,
                "hide_top_toolbar": true,
                "hide_legend": false,
                "hide_volume": false,
                "hotlist": false,
                "interval": "${widget.interval}",
                "locale": "en",
                "save_image": true,
                "style": "1",
                "symbol": "${widget.symbol}",
                "theme": "${widget.theme}",
                "timezone": "Etc/UTC",
                "backgroundColor": "#$backgroundColor",
                "gridColor": "#$gridColor",
                "withdateranges": true,
                "range": "1M",
                "allow_symbol_change": true,
                "autosize": true,
                "width": "100%",
                "height": "100%",
                "container_id": "chart-container"
            };
            
            const script = document.createElement('script');
            script.type = 'text/javascript';
            script.async = true;
            script.src = 'https://s3.tradingview.com/external-embedding/embed-widget-advanced-chart.js';
            script.innerHTML = JSON.stringify(config);
            
            script.onload = function() {
                console.log('TradingView script loaded successfully');
                chartLoaded = true;
                if (loadingEl) {
                    loadingEl.style.display = 'none';
                }
            };
            
            script.onerror = function() {
                console.error('Failed to load TradingView script');
                if (loadingEl) {
                    loadingEl.textContent = 'Failed to load chart';
                }
            };
            
            container.appendChild(script);
        }
        
        // Load chart when DOM is ready
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', loadTradingViewWidget);
        } else {
            loadTradingViewWidget();
        }
        
        // Handle orientation changes
        let resizeTimer;
        window.addEventListener('orientationchange', function() {
            console.log('Orientation changed');
            clearTimeout(resizeTimer);
            resizeTimer = setTimeout(function() {
                const container = document.getElementById('chart-container');
                // Only reload if chart was loaded
                if (chartLoaded) {
                    container.innerHTML = '<div class="loading" id="loading">Loading chart...</div>';
                    chartLoaded = false;
                    setTimeout(loadTradingViewWidget, 300);
                }
            }, 100);
        });
        
        // Handle window resize with debounce
        window.addEventListener('resize', function() {
            clearTimeout(resizeTimer);
            resizeTimer = setTimeout(function() {
                console.log('Window resized:', window.innerWidth, 'x', window.innerHeight);
                // TradingView handles resize automatically with autosize: true
            }, 250);
        });
        
        // Prevent scrolling issues
        document.addEventListener('touchmove', function(e) {
            if (e.target.closest('.tradingview-widget-container__widget')) {
                // Allow scrolling within the chart
                return;
            }
            e.preventDefault();
        }, { passive: false });
    </script>
</body>
</html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    print(
      'Rendering TradingViewChart: theme=${widget.theme}, symbol=${widget.symbol}, interval=${widget.interval}',
    );

    return Container(
      color: widget.theme == 'dark'
          ? const Color(0xFF1E1E1E)
          : AppColors.screenBackground,
      child: WebViewWidget(controller: _controller),
    );
  }
}