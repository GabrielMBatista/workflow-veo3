#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo "=========================================="
echo "  Baserow IDs Update Tool"
echo "=========================================="
echo ""

# Backup workflows
echo -e "${YELLOW}Creating backup...${NC}"
mkdir -p workflows/backup
cp workflows/*.json workflows/backup/ 2>/dev/null
echo -e "${GREEN}✓${NC} Backup created in workflows/backup/"
echo ""

# Collect IDs
echo "Enter your Baserow IDs:"
echo "(Find them in Baserow URL and field settings)"
echo ""

read -p "Database ID: " DB_ID
read -p "Table ID: " TABLE_ID
read -p "API Token: " API_TOKEN
echo ""

echo "Field IDs:"
read -p "session_id Field ID: " FIELD_SESSION
read -p "index Field ID: " FIELD_INDEX
read -p "prompt Field ID: " FIELD_PROMPT
read -p "status Field ID: " FIELD_STATUS
read -p "frame_base64 Field ID: " FIELD_FRAME
read -p "create_url_video Field ID: " FIELD_VIDEO
echo ""

# Validate inputs
if [ -z "$DB_ID" ] || [ -z "$TABLE_ID" ] || [ -z "$API_TOKEN" ]; then
    echo -e "${RED}Error: Database ID, Table ID, and API Token are required${NC}"
    exit 1
fi

# Update files
echo -e "${BLUE}Updating workflows...${NC}"

for file in workflows/*.json; do
    if [ -f "$file" ]; then
        # Skip backup folder
        if [[ $file == *"/backup/"* ]]; then
            continue
        fi
        
        filename=$(basename "$file")
        
        # Database and Table IDs
        sed -i.tmp "s/\"databaseId\": 292721/\"databaseId\": $DB_ID/g" "$file"
        sed -i.tmp "s/\"tableId\": 680992/\"tableId\": $TABLE_ID/g" "$file"
        
        # Table ID in URLs
        sed -i.tmp "s|table/680992/|table/$TABLE_ID/|g" "$file"
        
        # API Token
        sed -i.tmp "s/Token uWZOGSVeUvifM6eMdmbmHdYeZRtIuFSp/Token $API_TOKEN/g" "$file"
        sed -i.tmp "s/Token your-token-here/Token $API_TOKEN/g" "$file"
        
        # Field IDs (only if provided)
        [ ! -z "$FIELD_SESSION" ] && sed -i.tmp "s/\"fieldId\": 5621560/\"fieldId\": $FIELD_SESSION/g" "$file"
        [ ! -z "$FIELD_INDEX" ] && sed -i.tmp "s/\"fieldId\": 5621561/\"fieldId\": $FIELD_INDEX/g" "$file"
        [ ! -z "$FIELD_PROMPT" ] && sed -i.tmp "s/\"fieldId\": 5621563/\"fieldId\": $FIELD_PROMPT/g" "$file"
        [ ! -z "$FIELD_STATUS" ] && sed -i.tmp "s/\"fieldId\": 5621564/\"fieldId\": $FIELD_STATUS/g" "$file"
        [ ! -z "$FIELD_FRAME" ] && sed -i.tmp "s/\"fieldId\": 5621567/\"fieldId\": $FIELD_FRAME/g" "$file"
        [ ! -z "$FIELD_VIDEO" ] && sed -i.tmp "s/\"fieldId\": 5621568/\"fieldId\": $FIELD_VIDEO/g" "$file"
        
        # Remove temp files
        rm -f "$file.tmp"
        
        echo -e "${GREEN}✓${NC} $filename"
    fi
done

echo ""
echo "=========================================="
echo -e "${GREEN}  Update Complete!${NC}"
echo "=========================================="
echo ""
echo "Updated workflows are ready to import."
echo ""
echo "Next steps:"
echo "1. Import workflows to n8n"
echo "2. Configure credentials"
echo "3. Activate workflows"
echo ""
echo "Backup location: workflows/backup/"
echo ""