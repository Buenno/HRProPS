@{
    Rules = @{
        # Formatting rules

        PSUseConsistentIndentation = @{
            Enable = $true
            IndentationSize = 4
            PipelineIndentation = 'IncreaseIndentationAfterEveryPipeline'
            Kind = 'space'
        }

        PSUseConsistentWhitespace = @{
            Enable = $true
        }

        PSPlaceOpenBrace = @{
            Enable = $true
            OnSameLine = $true
            NewLineAfter = $true
        }

        PSPlaceCloseBrace = @{
            Enable = $true
            NewLineAfter = $true
        }

        PSUseConsistentBraces = @{
            Enable = $true
        }

        # Naming rules

        PSAvoidUsingCmdletAliases = @{
            Enable = $true
        }

        PSUseApprovedVerbs = @{
            Enable = $true
        }

        # Other rules

        PSProvideCommentHelp = @{
            Enable = $true
            ExportedOnly = $true
            BlockComment = $true
        }
    }
}