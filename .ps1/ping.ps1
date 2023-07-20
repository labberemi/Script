# Assurez-vous d'avoir installé le module ChartJS (si ce n'est pas déjà fait)
#Install-Module -Name ChartJS -Scope CurrentUser -Force

# Définir la plage d'adresses IP (modifier si nécessaire)
$StartIP = 100
$EndIP = 110
$IPPrefix = "192.168.0."

# Le reste du script dans une fonction
function Generate-PingResultsHTML {
    param (
        [string]$CompanyImageFile,
        [string]$OutputFile
    )

    function Show-ProgressBar {
        param (
            [int]$CurrentStep,
            [int]$TotalSteps
        )
        $percentage = ($CurrentStep / $TotalSteps) * 100
        Write-Progress -Activity "Pinging IP addresses" -Status "Étape $CurrentStep sur $TotalSteps" -PercentComplete $percentage
    }

    $Title = "Résultats de ping"
    $Date = Get-Date -Format "dd-MM-yyyy HH:mm:ss"

    $htmlContent = @"
    <html>
    <head>
    <title>$Title</title>
    <style>
        body {
            display: flex;
            justify-content: center;
            align-items: center;
            flex-direction: column;
            min-height: 100vh;
        }
        .logo {
            width: 200px;
            height: auto;
            margin-bottom: 20px;
        }
        .chart-container {
            margin-top: 20px;
            width: 80%;
            max-width: 800px;
        }
        .chart {
            width: 100%;
            height: 400px;
        }
        table {
            margin-bottom: 20px;
        }
        th, td {
            padding: 10px;
            text-align: center;
        }
    </style>
    </head>
    <body>
    <img class="logo" src="data:image/png;base64,$([Convert]::ToBase64String([IO.File]::ReadAllBytes($CompanyImageFile)))" alt="Logo de la compagnie">
    <h1>$Title</h1>
    <p>Date d'exécution : $Date</p>
    <table>
    
    <tr><th>Adresse IP</th><th>Résultat</th><th>Adresse IP</th><th>Résultat</th></tr>
"@

    $totalSteps = $EndIP - $StartIP + 1
    $currentStep = 0
    $countSuccess = 0
    $countFail = 0

    for ($i = $StartIP; $i -le $EndIP; $i++) {
        $currentStep++
        Show-ProgressBar -CurrentStep $currentStep -TotalSteps $totalSteps
        $ip = $IPPrefix + $i
        if (Test-Connection -ComputerName $ip -Count 1 -Quiet) {
            $htmlContent += "<td>$ip</td><td style='color:green'>Fonctionne</td>"
            $countSuccess++
        } else {
            $htmlContent += "<td>$ip</td><td style='color:red'>Ne fonctionne pas</td>"
            $countFail++
        }

        # Ajouter un saut de ligne après chaque deux adresses IP pour afficher deux colonnes
        if ($currentStep % 2 -eq 0) {
            $htmlContent += "</tr><tr>"
        }
    }

    # Vérifier s'il reste une adresse IP pour compléter la dernière ligne
    if ($currentStep % 2 -ne 0) {
        $htmlContent += "<td></td><td></td>"
    }

    $htmlContent += @"
    </tr>
    </table>
    <!-- Graphique en colonnes pour les résultats -->
    <div class="chart-container">
        <canvas class="chart" id="myChart"></canvas>
    </div>
    <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script type="text/javascript">
        var ctx = document.getElementById('myChart').getContext('2d');
        var myChart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: [''],
                datasets: [{
                    label: 'Pings réussis',
                    data: [$countSuccess],
                    backgroundColor: ['green'],
                    borderWidth: 1
                },
                {
                    label: 'Pings non réussis',
                    data: [$countFail],
                    backgroundColor: ['red'],
                    borderWidth: 1
                }]
            },
            options: {
                responsive: false,
                maintainAspectRatio: false,
                scales: {
                    yAxes: [{
                        ticks: {
                            beginAtZero: true,
                            stepSize: 1
                        }
                    }]
                },
                title: {
                    display: true,
                    text: 'Résultats de ping'
                },
                legend: {
                    display: true,
                    labels: {
                        fontColor: 'black'
                    },
                    align: 'center' // Option pour centrer la légende
                }
            }
        });
    </script>
    </body>
    </html>
"@

    $htmlContent | Out-File $OutputFile

    Write-Progress -Activity "Pinging IP addresses" -Completed
    Write-Host "Le ping est terminé. Les résultats ont été enregistrés dans $OutputFile."
}

# Utilisation de la fonction
Generate-PingResultsHTML -CompanyImageFile "ping.png" -OutputFile "ping_results.html"
