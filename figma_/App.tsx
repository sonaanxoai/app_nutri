import { useState } from 'react';
import { Menu, Settings, Camera, Share2, Save, BookOpen } from 'lucide-react';

export default function App() {
    const [isScanning] = useState(false);

    return (
        <div className="min-h-screen bg-gray-50 flex justify-center">
            {/* Mobile Container */}
            <div className="w-full max-w-md bg-white relative">
                {/* Status Bar */}
                <div className="flex justify-between items-center px-4 pt-3 pb-2 text-xs">
                    <span>10:09</span>
                    <div className="flex gap-1">
                        <div className="w-4 h-3 bg-black rounded-sm"></div>
                        <div className="w-4 h-3 bg-black rounded-sm"></div>
                        <div className="w-4 h-3 bg-black rounded-sm"></div>
                    </div>
                </div>

                {/* Header */}
                <div className="flex items-center justify-between px-4 py-3 bg-white border-b">
                    <button className="w-8 h-8 rounded-full bg-green-100 flex items-center justify-center">
                        <Menu size={18} className="text-green-700" />
                    </button>
                    <h1 className="text-lg font-semibold text-gray-800">NutriScan AI</h1>
                    <div className="flex gap-2">
                        <button className="w-8 h-8 rounded-full bg-gray-100 flex items-center justify-center">
                            <Camera size={16} className="text-gray-700" />
                        </button>
                        <button className="w-8 h-8 rounded-full bg-gray-100 flex items-center justify-center">
                            <Settings size={16} className="text-gray-700" />
                        </button>
                    </div>
                </div>

                {/* Camera Preview with Overlay */}
                <div className="relative h-64 bg-gray-900">
                    {/* Food Image */}
                    <img
                        src="/src/imports/image.png"
                        alt="Vietnamese Pho"
                        className="w-full h-full object-cover"
                    />

                    {/* Scanning Overlay */}
                    {isScanning && (
                        <div className="absolute inset-0 bg-black bg-opacity-40 flex items-center justify-center">
                            <div className="bg-white bg-opacity-90 px-6 py-2 rounded-full">
                                <span className="text-sm font-medium text-gray-800">SCANNING...</span>
                            </div>
                        </div>
                    )}

                    {/* Calorie Circle Overlay */}
                    <div className="absolute bottom-4 left-1/2 -translate-x-1/2">
                        <div className="relative w-24 h-24">
                            {/* Circular Progress */}
                            <svg className="w-24 h-24 -rotate-90">
                                <circle
                                    cx="48"
                                    cy="48"
                                    r="42"
                                    stroke="#e5e7eb"
                                    strokeWidth="6"
                                    fill="white"
                                />
                                <circle
                                    cx="48"
                                    cy="48"
                                    r="42"
                                    stroke="#10b981"
                                    strokeWidth="6"
                                    fill="none"
                                    strokeDasharray={`${(450 / 2000) * 264} 264`}
                                    strokeLinecap="round"
                                />
                            </svg>
                            {/* Calorie Text */}
                            <div className="absolute inset-0 flex flex-col items-center justify-center">
                                <span className="text-2xl font-bold text-gray-800">450</span>
                                <span className="text-xs text-gray-600">Cal</span>
                            </div>
                        </div>
                    </div>

                    {/* Macro Nutrients */}
                    <div className="absolute bottom-4 left-4 bg-white bg-opacity-90 rounded-lg px-3 py-1.5 flex items-center gap-3">
                        <div className="flex items-center gap-1">
                            <div className="w-2 h-2 rounded-full bg-red-500"></div>
                            <span className="text-xs font-medium">30g</span>
                        </div>
                        <div className="flex items-center gap-1">
                            <div className="w-2 h-2 rounded-full bg-blue-500"></div>
                            <span className="text-xs font-medium">20g</span>
                        </div>
                    </div>
                </div>

                {/* Scan Result Card */}
                <div className="px-4 py-4 bg-white">
                    <div className="bg-gray-50 rounded-2xl p-4 shadow-sm">
                        {/* Food Title */}
                        <div className="mb-3">
                            <span className="text-xs text-gray-500 uppercase">Scan Result</span>
                            <h2 className="text-xl font-bold text-gray-800 mt-1">Vietnamese Pho</h2>
                            <div className="text-2xl font-bold text-green-600 mt-1">450 <span className="text-sm text-gray-600">Calories</span></div>
                        </div>

                        {/* Macro Breakdown */}
                        <div className="grid grid-cols-3 gap-2 mb-4">
                            <MacroCard color="bg-green-100 text-green-700" label="Calories" value="450" unit="kcal" />
                            <MacroCard color="bg-red-100 text-red-700" label="Protein" value="30" unit="g" />
                            <MacroCard color="bg-yellow-100 text-yellow-700" label="Fat" value="20" unit="g" />
                        </div>

                        <div className="grid grid-cols-3 gap-2 mb-4">
                            <MacroCard color="bg-orange-100 text-orange-700" label="Saturated" value="5" unit="g" />
                            <MacroCard color="bg-blue-100 text-blue-700" label="Carbs" value="35" unit="g" />
                            <MacroCard color="bg-purple-100 text-purple-700" label="Fiber" value="2" unit="g" />
                        </div>

                        {/* Ingredients */}
                        <div className="mb-4">
                            <h3 className="text-sm font-semibold text-gray-700 mb-2">Ingredients:</h3>
                            <div className="space-y-1.5">
                                <IngredientItem color="bg-amber-100" icon="🍜" name="Rice Noodles" amount="(300g)" />
                                <IngredientItem color="bg-red-100" icon="🥩" name="Beef" amount="(150g)" />
                                <IngredientItem color="bg-orange-100" icon="🍲" name="Broth" amount="(400ml)" />
                                <IngredientItem color="bg-green-100" icon="🌱" name="Bean Sprouts" amount="(50g)" />
                                <IngredientItem color="bg-green-100" icon="🌿" name="Herbs" subtext="(Cilantro, Basil)" />
                                <IngredientItem color="bg-yellow-100" icon="⭐" name="Spices" subtext="(Star Anise, Cinnamon)" />
                                <IngredientItem color="bg-green-100" icon="🧅" name="Both" subtext="(Scallion Basil)" />
                            </div>
                        </div>

                        {/* Action Buttons */}
                        <div className="grid grid-cols-3 gap-2">
                            <ActionButton icon={<BookOpen size={18} />} label="Add to Diary" color="bg-green-500 hover:bg-green-600" />
                            <ActionButton icon={<Share2 size={18} />} label="Share" color="bg-gray-200 hover:bg-gray-300 text-gray-700" />
                            <ActionButton icon={<Save size={18} />} label="Save" color="bg-gray-200 hover:bg-gray-300 text-gray-700" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}

function MacroCard({ color, label, value, unit }: { color: string; label: string; value: string; unit: string }) {
    return (
        <div className={`${color} rounded-lg p-2.5 text-center`}>
            <div className="text-xs font-medium opacity-80 mb-0.5">{label}</div>
            <div className="font-bold text-lg">{value}<span className="text-xs ml-0.5">{unit}</span></div>
        </div>
    );
}

function IngredientItem({ color, icon, name, amount, subtext }: {
    color: string;
    icon: string;
    name: string;
    amount?: string;
    subtext?: string;
}) {
    return (
        <div className="flex items-center gap-2">
            <div className={`${color} w-7 h-7 rounded-full flex items-center justify-center text-sm`}>
                {icon}
            </div>
            <div className="flex-1 text-sm">
                <span className="text-gray-800 font-medium">{name}</span>
                {amount && <span className="text-gray-600 ml-1">{amount}</span>}
                {subtext && <span className="text-gray-500 ml-1">{subtext}</span>}
            </div>
        </div>
    );
}

function ActionButton({ icon, label, color }: { icon: React.ReactNode; label: string; color: string }) {
    return (
        <button className={`${color} text-white rounded-lg py-2.5 px-3 flex flex-col items-center justify-center gap-1 transition-colors`}>
            {icon}
            <span className="text-xs font-medium">{label}</span>
        </button>
    );
}
