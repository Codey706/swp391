// Trang tổng quan Organizer: biểu đồ doanh thu 7 / 30 / 90 ngày (Chart.js)
(function () {
    var canvas = document.getElementById('revenueChart');
    if (!canvas || typeof Chart === 'undefined') {
        return;
    }
    var labels = JSON.parse(canvas.dataset.labels || '[]');
    var values = JSON.parse(canvas.dataset.values || '[]');
    var money = new Intl.NumberFormat('vi-VN');

    var chart = new Chart(canvas, {
        type: 'line',
        data: {
            labels: [],
            datasets: [{
                label: 'Doanh thu',
                data: [],
                borderColor: '#ff7043',
                backgroundColor: function (ctx) {
                    var area = ctx.chart.chartArea;
                    if (!area) {
                        return 'rgba(255, 112, 67, 0.12)';
                    }
                    var g = ctx.chart.ctx.createLinearGradient(0, area.top, 0, area.bottom);
                    g.addColorStop(0, 'rgba(255, 112, 67, 0.28)');
                    g.addColorStop(1, 'rgba(255, 112, 67, 0)');
                    return g;
                },
                fill: true,
                tension: 0.35,
                borderWidth: 2,
                pointRadius: 3,
                pointBackgroundColor: '#fff',
                pointBorderColor: '#ff7043',
                pointBorderWidth: 2
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {display: false},
                tooltip: {
                    callbacks: {
                        label: function (ctx) {
                            return 'Doanh thu: ' + money.format(ctx.parsed.y) + ' ₫';
                        }
                    }
                }
            },
            scales: {
                x: {grid: {display: false}, border: {display: false}, ticks: {maxTicksLimit: 10, color: '#7a8499'}},
                y: {
                    beginAtZero: true,
                    border: {display: false},
                    grid: {color: '#eef1f8'},
                    ticks: {
                        color: '#7a8499',
                        callback: function (v) {
                            return v >= 1000000 ? (v / 1000000) + ' tr' : money.format(v);
                        }
                    }
                }
            }
        }
    });

    function show(days) {
        var from = Math.max(0, labels.length - days);
        chart.data.labels = labels.slice(from);
        chart.data.datasets[0].data = values.slice(from);
        chart.data.datasets[0].pointRadius = days > 30 ? 0 : 3;
        chart.update();
    }

    var buttons = document.querySelectorAll('.js-range');
    buttons.forEach(function (btn) {
        btn.addEventListener('click', function () {
            buttons.forEach(function (b) {
                b.classList.remove('active');
            });
            btn.classList.add('active');
            show(parseInt(btn.dataset.range, 10));
        });
    });
    show(7);
})();
