# Assurez-vous d'avoir install� le module ChartJS (si ce n'est pas d�j� fait)
#Install-Module -Name ChartJS -Scope CurrentUser -Force

# D�finir la plage d'adresses IP (modifier si n�cessaire)
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
        Write-Progress -Activity "Pinging IP addresses" -Status "�tape $CurrentStep sur $TotalSteps" -PercentComplete $percentage
    }

    $Title = "R�sultats de ping"
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
    <p>Date d'ex�cution : $Date</p>
    <table>
    
    <tr><th>Adresse IP</th><th>R�sultat</th><th>Adresse IP</th><th>R�sultat</th></tr>
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

        # Ajouter un saut de ligne apr�s chaque deux adresses IP pour afficher deux colonnes
        if ($currentStep % 2 -eq 0) {
            $htmlContent += "</tr><tr>"
        }
    }

    # V�rifier s'il reste une adresse IP pour compl�ter la derni�re ligne
    if ($currentStep % 2 -ne 0) {
        $htmlContent += "<td></td><td></td>"
    }

    $htmlContent += @"
    </tr>
    </table>
    <!-- Graphique en colonnes pour les r�sultats -->
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
                    label: 'Pings r�ussis',
                    data: [$countSuccess],
                    backgroundColor: ['green'],
                    borderWidth: 1
                },
                {
                    label: 'Pings non r�ussis',
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
                    text: 'R�sultats de ping'
                },
                legend: {
                    display: true,
                    labels: {
                        fontColor: 'black'
                    },
                    align: 'center' // Option pour centrer la l�gende
                }
            }
        });
    </script>
    </body>
    </html>
"@

    $htmlContent | Out-File $OutputFile

    Write-Progress -Activity "Pinging IP addresses" -Completed
    Write-Host "Le ping est termin�. Les r�sultats ont �t� enregistr�s dans $OutputFile."
}

# Utilisation de la fonction
Generate-PingResultsHTML -CompanyImageFile "ping.png" -OutputFile "ping_results.html"
